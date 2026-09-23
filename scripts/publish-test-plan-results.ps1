param(
    [ValidateSet('functional', 'accessibility')][string]$Suite,
    [int]$PlanId = 3201,
    [int]$SuiteId,
    [int]$ExpectedCount,
    [string]$JunitPath,
    [string]$CollectionUri = $env:SYSTEM_COLLECTIONURI,
    [string]$Project = $env:SYSTEM_TEAMPROJECT,
    [string]$BuildId = $env:BUILD_BUILDID
)

$ErrorActionPreference = 'Stop'

function Read-PlaywrightJUnit {
    param([string]$Path)

    $reportDirectory = Split-Path (Resolve-Path $Path).Path
    $settings = [System.Xml.XmlReaderSettings]::new()
    $settings.DtdProcessing = [System.Xml.DtdProcessing]::Prohibit
    $reader = [System.Xml.XmlReader]::Create((Resolve-Path $Path).Path, $settings)
    try {
        $document = [System.Xml.XmlDocument]::new()
        $document.Load($reader)
    }
    finally {
        $reader.Dispose()
    }

    foreach ($test in $document.SelectNodes('/testsuites/testsuite/testcase | /testsuite/testcase')) {
        $failure = $test.SelectSingleNode('failure | error')
        $outcome = if ($failure) { 'Failed' } elseif ($test.SelectSingleNode('skipped')) { 'NotExecuted' } else { 'Passed' }
        $duration = [double]::Parse($test.GetAttribute('time'), [cultureinfo]::InvariantCulture) * 1000
        if (-not [double]::IsFinite($duration) -or $duration -lt 0) {
            throw 'JUnit duration must be finite and nonnegative.'
        }
        $attachments = @(foreach ($output in $test.SelectNodes('system-out')) {
            foreach ($reference in [regex]::Matches($output.InnerText, '\[\[ATTACHMENT\|([^\r\n]+?)\]\]')) {
                $relativePath = $reference.Groups[1].Value.Replace('\', '/').Trim()
                $attachmentPath = [IO.Path]::GetFullPath((Join-Path $reportDirectory $relativePath))
                $relativeToReport = [IO.Path]::GetRelativePath($reportDirectory, $attachmentPath)
                if ([IO.Path]::IsPathRooted($relativePath) -or $relativeToReport -eq '..' -or
                    $relativeToReport.StartsWith("..$([IO.Path]::DirectorySeparatorChar)")) {
                    throw "JUnit attachment must be inside the report directory: $relativePath"
                }
                if (-not (Test-Path -LiteralPath $attachmentPath -PathType Leaf)) {
                    throw "JUnit attachment not found: $relativePath"
                }
                $attachmentPath
            }
        })
        [pscustomobject]@{
            Name = $test.GetAttribute('name')
            Storage = $test.GetAttribute('classname')
            Outcome = $outcome
            Duration = $duration
            ErrorMessage = if ($failure) { $failure.InnerText } else { '' }
            Attachments = @($attachments | Select-Object -Unique)
        }
    }
}

function Get-PlanResultMappings {
    param([array]$Results, [array]$Cases, [array]$Points, [int]$Count)

    if ($Count -le 0 -or $Results.Count -ne $Count -or $Cases.Count -ne $Count -or $Points.Count -ne $Count) {
        throw "Expected exactly $Count results, test cases and test points; found $($Results.Count), $($Cases.Count), $($Points.Count)."
    }
    $usedCases = [System.Collections.Generic.HashSet[int]]::new()
    foreach ($result in $Results) {
        $matches = @($Cases | Where-Object {
            $_.fields.'Microsoft.VSTS.TCM.AutomatedTestName' -ceq $result.Name -and
            $_.fields.'Microsoft.VSTS.TCM.AutomatedTestStorage' -ceq $result.Storage
        })
        if ($matches.Count -ne 1) {
            throw "Expected one automation association for '$($result.Name)' in '$($result.Storage)'."
        }
        $case = $matches[0]
        if ($case.fields.'Microsoft.VSTS.TCM.AutomationStatus' -ne 'Automated' -or
            -not $case.fields.'Microsoft.VSTS.TCM.AutomatedTestId' -or -not $usedCases.Add([int]$case.id)) {
            throw "Missing automation identity or duplicate result for test case $($case.id)."
        }
        $matchingPoints = @($Points | Where-Object { [int]$_.testCase.id -eq [int]$case.id })
        if ($matchingPoints.Count -ne 1) {
            throw "Expected exactly one configuration/test point for test case $($case.id)."
        }
        [pscustomobject]@{ Result = $result; Case = $case; Point = $matchingPoints[0] }
    }
}

function Invoke-TestPlanApi {
    param([string]$Path, [string]$Method = 'GET', $Body)

    $separator = if ($Path.Contains('?')) { '&' } else { '?' }
    $parameters = @{
        Uri = "$($script:TestPlanBaseUri)/$Path${separator}api-version=7.1"
        Method = $Method
        Headers = $script:TestPlanHeaders
        TimeoutSec = 60
    }
    if ($null -ne $Body) {
        $parameters.ContentType = 'application/json'
        $parameters.Body = ConvertTo-Json -InputObject $Body -Depth 15 -Compress
    }
    Invoke-RestMethod @parameters
}

function Publish-TestPlanResults {
    param([string]$Name, [int]$Plan, [int]$TestSuite, [int]$Count, [string]$Path, [string]$Build)

    if (-not $env:SYSTEM_STAGENAME -or -not $env:SYSTEM_PHASENAME -or -not $env:SYSTEM_JOBNAME -or
        $env:SYSTEM_STAGEATTEMPT -notmatch '^[1-9]\d*$' -or
        $env:SYSTEM_PHASEATTEMPT -notmatch '^[1-9]\d*$' -or
        $env:SYSTEM_JOBATTEMPT -notmatch '^[1-9]\d*$') {
        throw 'Pipeline stage, phase and job names and attempts are required for stage test summaries.'
    }
    $results = @(Read-PlaywrightJUnit -Path $Path)
    $points = @((Invoke-TestPlanApi "test/Plans/$Plan/Suites/$TestSuite/points").value)
    $caseIds = @($points | ForEach-Object { $_.testCase.id }) -join ','
    if (-not $caseIds) { throw "Suite $TestSuite has no test points." }
    $cases = @((Invoke-TestPlanApi "wit/workitems?ids=$caseIds").value)
    $mappings = @(Get-PlanResultMappings -Results $results -Cases $cases -Points $points -Count $Count)
    $buildUrl = "$($CollectionUri.TrimEnd('/'))/$([uri]::EscapeDataString($Project))/_build/results?buildId=$Build"
    $run = Invoke-TestPlanApi -Path 'test/runs' -Method POST -Body @{
        name = "Playwright $Name - Plan $Plan - Build $Build - Attempt $env:SYSTEM_JOBATTEMPT"
        automated = $true
        plan = @{ id = "$Plan" }
        pointIds = @($mappings | ForEach-Object { [int]$_.Point.id })
        build = @{ id = $Build }
        pipelineReference = @{
            pipelineId = [int]$Build
            stageReference = @{ stageName = $env:SYSTEM_STAGENAME; attempt = [int]$env:SYSTEM_STAGEATTEMPT }
            phaseReference = @{ phaseName = $env:SYSTEM_PHASENAME; attempt = [int]$env:SYSTEM_PHASEATTEMPT }
            jobReference = @{ jobName = $env:SYSTEM_JOBNAME; attempt = [int]$env:SYSTEM_JOBATTEMPT }
        }
        comment = "Actual Playwright JUnit outcomes. Reports, screenshots and traces: $buildUrl&view=artifacts"
    }

    try {
        $seeded = @((Invoke-TestPlanApi "test/runs/$($run.id)/results").value)
        if ($seeded.Count -ne $Count) { throw "Run $($run.id) did not seed all $Count test points." }
        $updates = @(foreach ($mapping in $mappings) {
            $target = @($seeded | Where-Object { [int]$_.testPoint.id -eq [int]$mapping.Point.id })
            if ($target.Count -ne 1) { throw "Missing seeded result for point $($mapping.Point.id)." }
            $message = $mapping.Result.ErrorMessage
            @{
                id = $target[0].id
                state = 'Completed'
                outcome = $mapping.Result.Outcome
                durationInMs = $mapping.Result.Duration
                automatedTestName = $mapping.Result.Name
                automatedTestStorage = $mapping.Result.Storage
                automatedTestId = $mapping.Case.fields.'Microsoft.VSTS.TCM.AutomatedTestId'
                automatedTestType = 'JUnit'
                errorMessage = $message.Substring(0, [Math]::Min(1000, $message.Length))
                comment = "Original JUnit attached to run. Reports, screenshots and traces: $buildUrl&view=artifacts"
            }
        })
        Invoke-TestPlanApi -Path "test/runs/$($run.id)/results" -Method PATCH -Body $updates | Out-Null
        foreach ($mapping in $mappings) {
            $target = @($seeded | Where-Object { [int]$_.testPoint.id -eq [int]$mapping.Point.id })[0]
            $attachmentIndex = 0
            foreach ($attachmentPath in $mapping.Result.Attachments) {
                $attachmentIndex++
                Invoke-TestPlanApi -Path "test/runs/$($run.id)/results/$($target.id)/attachments" -Method POST -Body @{
                    stream = [Convert]::ToBase64String([IO.File]::ReadAllBytes($attachmentPath))
                    fileName = "$attachmentIndex-$([IO.Path]::GetFileName($attachmentPath))"
                    attachmentType = 'GeneralAttachment'
                    comment = "Playwright evidence: $([IO.Path]::GetRelativePath((Split-Path (Resolve-Path $Path).Path), $attachmentPath))"
                } | Out-Null
            }
        }
        Invoke-TestPlanApi -Path "test/runs/$($run.id)/attachments" -Method POST -Body @{
            stream = [Convert]::ToBase64String([IO.File]::ReadAllBytes((Resolve-Path $Path).Path))
            fileName = "$Name-junit.xml"
            attachmentType = 'GeneralAttachment'
            comment = 'Original Playwright JUnit report, including complete failure details.'
        } | Out-Null
        Invoke-TestPlanApi -Path "test/runs/$($run.id)" -Method PATCH -Body @{ state = 'Completed' } | Out-Null
    }
    catch {
        $publicationError = $_
        try {
            Invoke-TestPlanApi -Path "test/runs/$($run.id)" -Method PATCH -Body @{
                state = 'Aborted'
                comment = 'Test Plan publication failed; inspect the pipeline publisher logs. Do not treat this as a completed test run.'
            } | Out-Null
        }
        catch { Write-Warning "Could not abort incomplete test run $($run.id)." }
        throw $publicationError
    }

    $published = @((Invoke-TestPlanApi "test/Plans/$Plan/Suites/$TestSuite/points").value)
    foreach ($mapping in $mappings) {
        $point = @($published | Where-Object { [int]$_.id -eq [int]$mapping.Point.id })
        if ($point.Count -ne 1 -or [int]$point[0].lastTestRun.id -ne [int]$run.id -or
            $point[0].outcome -ne $mapping.Result.Outcome) {
            throw "Test point $($mapping.Point.id) does not reflect run $($run.id) and its actual outcome. Check for concurrent builds."
        }
    }
    Write-Host "Published and verified $Count $Name outcomes in plan $Plan, suite $TestSuite, run $($run.id)."
    if ($results.Outcome -contains 'Failed') { throw 'Playwright reported test failures; Test Plans outcomes were published successfully.' }
}

if ($MyInvocation.InvocationName -ne '.') {
    if (-not $Suite -or $SuiteId -le 0 -or $ExpectedCount -le 0 -or -not $JunitPath -or
        -not $CollectionUri -or -not $Project -or $BuildId -notmatch '^\d+$' -or -not $env:SYSTEM_ACCESSTOKEN) {
        throw 'Suite, SuiteId, ExpectedCount, JunitPath and pipeline context (including SYSTEM_ACCESSTOKEN) are required.'
    }
    $collection = [uri]$CollectionUri
    if ($collection.Scheme -ne 'https') { throw 'CollectionUri must use HTTPS.' }
    $script:TestPlanBaseUri = "$($CollectionUri.TrimEnd('/'))/$([uri]::EscapeDataString($Project))/_apis"
    $script:TestPlanHeaders = @{ Authorization = "Bearer $env:SYSTEM_ACCESSTOKEN" }
    Publish-TestPlanResults -Name $Suite -Plan $PlanId -TestSuite $SuiteId -Count $ExpectedCount -Path $JunitPath -Build $BuildId
}