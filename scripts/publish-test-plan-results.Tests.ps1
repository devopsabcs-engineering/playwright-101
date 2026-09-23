$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'publish-test-plan-results.ps1')

function Assert-Equal {
    param($Actual, $Expected)
    if ($Actual -cne $Expected) { throw "Expected '$Expected', got '$Actual'." }
}

function Assert-Throws {
    param([scriptblock]$Action, [string]$Pattern)
    try { & $Action }
    catch {
        if ($_.Exception.Message -notmatch $Pattern) { throw }
        return
    }
    throw "Expected an error matching '$Pattern'."
}

Assert-Throws {
    & (Join-Path $PSScriptRoot 'publish-test-plan-results.ps1') `
        -Suite functional -SuiteId 3203 -ExpectedCount 9 -JunitPath 'unused.xml' -BuildId 'invalid'
} 'pipeline context'

$publisherPath = Join-Path $PSScriptRoot 'publish-test-plan-results.ps1'
& {
    . $publisherPath -Suite functional -SuiteId 3203 -ExpectedCount 9 -JunitPath 'unused.xml' -BuildId 'invalid'
}
Assert-Throws {
    . {
        & $publisherPath -Suite functional -SuiteId 3203 -ExpectedCount 9 -JunitPath 'unused.xml' -BuildId 'invalid'
    }
} 'pipeline context'

$fixtureDirectory = Join-Path ([IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString())
$fixture = Join-Path $fixtureDirectory 'junit.xml'
$pipelineEnvironment = @{
    SYSTEM_STAGENAME = 'Validation'
    SYSTEM_STAGEATTEMPT = '2'
    SYSTEM_PHASENAME = 'Playwright'
    SYSTEM_PHASEATTEMPT = '3'
    SYSTEM_JOBNAME = 'Functional'
    SYSTEM_JOBATTEMPT = '4'
}
$originalEnvironment = @{}
try {
    foreach ($variable in $pipelineEnvironment.Keys) {
        $originalEnvironment[$variable] = [Environment]::GetEnvironmentVariable($variable)
        [Environment]::SetEnvironmentVariable($variable, $pipelineEnvironment[$variable])
    }
    $env:SYSTEM_STAGEATTEMPT = '0'
    Assert-Throws { Publish-TestPlanResults functional 3201 3203 4 $fixture '4937' } 'stage test summaries'
    $env:SYSTEM_STAGEATTEMPT = '2'
    [IO.Directory]::CreateDirectory((Join-Path $fixtureDirectory 'retry')) | Out-Null
    [IO.File]::WriteAllBytes((Join-Path $fixtureDirectory 'screenshot.png'), [byte[]]@(137, 80, 78, 71))
    [IO.File]::WriteAllBytes((Join-Path $fixtureDirectory 'retry/screenshot.png'), [byte[]]@(1, 2, 3))
    [IO.File]::WriteAllText($fixture, @'
<testsuites><testsuite>
<testcase name="pass &amp; retry" classname="sample.spec.ts" time="1.25"><system-out>[[ATTACHMENT|screenshot.png]]</system-out></testcase>
<testcase name="failure-demo" classname="sample.spec.ts" time="2"><failure><![CDATA[Expected true, got false]]></failure><system-out>
[[ATTACHMENT|screenshot.png]]
[[ATTACHMENT|retry\screenshot.png]]
[[ATTACHMENT|screenshot.png]]
</system-out></testcase>
<testcase name="skip" classname="sample.spec.ts" time="0"><skipped /></testcase>
<testcase name="error" classname="sample.spec.ts" time="3"><error>timeout</error></testcase>
</testsuite></testsuites>
'@)
    $results = @(Read-PlaywrightJUnit $fixture)
    Assert-Equal $results.Count 4
    Assert-Equal ($results.Outcome -join ',') 'Passed,Failed,NotExecuted,Failed'
    Assert-Equal $results[0].Name 'pass & retry'
    Assert-Equal $results[0].Duration 1250
    Assert-Equal $results[1].ErrorMessage 'Expected true, got false'
    Assert-Equal $results[0].Attachments.Count 1
    Assert-Equal $results[1].Attachments.Count 2
    Assert-Equal $results[2].Attachments.Count 0
    $invalidFixture = Join-Path $fixtureDirectory 'invalid.xml'
    [IO.File]::WriteAllText($invalidFixture, '<testsuite><testcase time="0"><system-out>[[ATTACHMENT|missing.png]]</system-out></testcase></testsuite>')
    Assert-Throws { Read-PlaywrightJUnit $invalidFixture } 'attachment not found'
    [IO.File]::WriteAllText($invalidFixture, '<testsuite><testcase time="0"><system-out>[[ATTACHMENT|../outside.png]]</system-out></testcase></testsuite>')
    Assert-Throws { Read-PlaywrightJUnit $invalidFixture } 'inside the report directory'
    $cases = @(for ($index = 0; $index -lt 4; $index++) {
        @{ id = 3206 + $index; fields = @{
            'Microsoft.VSTS.TCM.AutomatedTestName' = $results[$index].Name
            'Microsoft.VSTS.TCM.AutomatedTestStorage' = $results[$index].Storage
            'Microsoft.VSTS.TCM.AutomatedTestId' = [guid]::NewGuid().ToString()
            'Microsoft.VSTS.TCM.AutomationStatus' = 'Automated'
        } }
    })
    $points = @(for ($index = 0; $index -lt 4; $index++) {
        @{ id = 907 + $index; testCase = @{ id = "$(3206 + $index)" } }
    })
    $mapped = @(Get-PlanResultMappings $results $cases $points 4)
    Assert-Equal $mapped.Count 4
    Assert-Throws { Get-PlanResultMappings $results $cases $points 9 } 'Expected exactly'
    Assert-Throws { Get-PlanResultMappings @($results[0], $results[0], $results[2], $results[3]) $cases $points 4 } 'duplicate'
    $cases[0].fields.'Microsoft.VSTS.TCM.AutomatedTestStorage' = 'wrong.spec.ts'
    Assert-Throws { Get-PlanResultMappings $results $cases $points 4 } 'one automation association'
    $cases[0].fields.'Microsoft.VSTS.TCM.AutomatedTestStorage' = 'sample.spec.ts'
    Assert-Throws { Get-PlanResultMappings $results $cases @($points[0], $points[0], $points[2], $points[3]) 4 } 'one configuration'

    $script:TestPlanBaseUri = 'https://example.test/project/_apis'
    $script:TestPlanHeaders = @{}
    function Invoke-RestMethod {
        param($Uri, $Method, $Headers, $TimeoutSec)
        Assert-Equal $Uri 'https://example.test/project/_apis/wit/workitems?ids=3206,3207&api-version=7.1'
    }
    Invoke-TestPlanApi 'wit/workitems?ids=3206,3207'
    Remove-Item Function:Invoke-RestMethod

    $script:updates = @()
    $script:completed = $false
    $script:aborted = $false
    $script:attachment = $false
    $script:resultAttachments = @()
    $script:rejectAttachment = $false
    $script:rejectResults = $false
    $CollectionUri = 'https://dev.azure.com/example/'
    $Project = 'project'
    function Invoke-TestPlanApi {
        param([string]$Path, [string]$Method = 'GET', $Body)
        switch -Regex ($Path) {
            '^test/Plans/3201/Suites/3203/points$' {
                if ($script:completed) {
                    return @{ value = @($mapped | ForEach-Object {
                        @{ id = $_.Point.id; outcome = $_.Result.Outcome; lastTestRun = @{ id = '500' } }
                    }) }
                }
                return @{ value = $points }
            }
            '^wit/workitems\?ids=' { return @{ value = $cases } }
            '^test/runs$' {
                Assert-Equal $Method 'POST'
                Assert-Equal $Body.automated $true
                Assert-Equal $Body.plan.id '3201'
                Assert-Equal $Body.build.id '4937'
                Assert-Equal $Body.pipelineReference.pipelineId 4937
                Assert-Equal $Body.pipelineReference.stageReference.stageName 'Validation'
                Assert-Equal $Body.pipelineReference.stageReference.attempt 2
                Assert-Equal $Body.pipelineReference.phaseReference.phaseName 'Playwright'
                Assert-Equal $Body.pipelineReference.phaseReference.attempt 3
                Assert-Equal $Body.pipelineReference.jobReference.jobName 'Functional'
                Assert-Equal $Body.pipelineReference.jobReference.attempt 4
                Assert-Equal ($Body.pointIds -join ',') '907,908,909,910'
                return @{ id = 500 }
            }
            '^test/runs/500/results$' {
                if ($Method -eq 'PATCH') {
                    if ($script:rejectResults) { throw 'Mock publication rejected' }
                    $script:updates = $Body
                    return @{}
                }
                return @{ value = @($points | ForEach-Object { @{ id = $_.id + 100000; testPoint = @{ id = $_.id } } }) }
            }
            '^test/runs/500/attachments$' {
                Assert-Equal $Method 'POST'
                Assert-Equal ([Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($Body.stream))) ([IO.File]::ReadAllText($fixture))
                $script:attachment = $true
                return @{}
            }
            '^test/runs/500/results/(100907|100908)/attachments$' {
                Assert-Equal $Method 'POST'
                if ($script:rejectAttachment) { throw 'Mock attachment rejected' }
                $script:resultAttachments += @{ Path = $Path; Body = $Body }
                return @{}
            }
            '^test/runs/500$' {
                Assert-Equal $Method 'PATCH'
                $script:completed = $Body.state -eq 'Completed'
                $script:aborted = $Body.state -eq 'Aborted'
                return @{}
            }
            default { throw "Unexpected request $Method $Path" }
        }
    }
    Assert-Throws { Publish-TestPlanResults functional 3201 3203 4 $fixture '4937' } 'test failures; Test Plans outcomes were published successfully'
    Assert-Equal ($script:updates.outcome -join ',') 'Passed,Failed,NotExecuted,Failed'
    Assert-Equal $script:completed $true
    Assert-Equal $script:attachment $true
    Assert-Equal $script:aborted $false
    Assert-Equal $script:resultAttachments.Count 3
    Assert-Equal ($script:resultAttachments.Path -join ',') 'test/runs/500/results/100907/attachments,test/runs/500/results/100908/attachments,test/runs/500/results/100908/attachments'
    Assert-Equal ($script:resultAttachments.Body.fileName -join ',') '1-screenshot.png,1-screenshot.png,2-screenshot.png'
    Assert-Equal $script:resultAttachments[0].Body.stream ([Convert]::ToBase64String([byte[]]@(137, 80, 78, 71)))
    Assert-Equal $script:resultAttachments[2].Body.stream ([Convert]::ToBase64String([byte[]]@(1, 2, 3)))
    $script:completed = $false
    $script:rejectAttachment = $true
    Assert-Throws { Publish-TestPlanResults functional 3201 3203 4 $fixture '4937' } 'Mock attachment rejected'
    Assert-Equal $script:aborted $true
    $script:rejectAttachment = $false
    $script:completed = $false
    $script:rejectResults = $true
    Assert-Throws { Publish-TestPlanResults functional 3201 3203 4 $fixture '4937' } 'Mock publication rejected'
    Assert-Equal $script:aborted $true
    Write-Host 'PASS: JUnit outcomes, strict mappings, API URI, publication lifecycle, attachment, failure exit and abort handling.'
}
finally {
    foreach ($variable in $originalEnvironment.Keys) {
        [Environment]::SetEnvironmentVariable($variable, $originalEnvironment[$variable])
    }
    Remove-Item $fixtureDirectory -Recurse -ErrorAction SilentlyContinue
}