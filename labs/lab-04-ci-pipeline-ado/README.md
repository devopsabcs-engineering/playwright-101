---
layout: default
title: "Lab 04: CI/CD Pipeline (Azure DevOps)"
nav_order: 7
description: "Automate Playwright tests with Azure DevOps Pipelines"
permalink: /labs/lab-04-ci-pipeline-ado/
---

| | |
|---|---|
| **Duration** | 15 minutes |
| **Level** | Beginner |
| **Type** | Demo + Configuration |

## Learning Objectives

After completing this lab, you will be able to:

* Understand CI/CD pipeline concepts for test automation
* Read and modify an Azure DevOps YAML pipeline
* Create a pipeline in Azure DevOps from an existing YAML file
* View test results and artifacts in Azure DevOps
* Decide when to run tests (push, PR, schedule)

## Prerequisites

* Lab 03 completed
* An Azure DevOps organization and project
* Push access to the Azure DevOps (or mirrored GitHub) repository

> This lab uses [GitHub Actions](../lab-04-ci-pipeline/) instead if your team's
> repository lives on GitHub rather than Azure Repos.

## Exercises

### Exercise 1: Review the Pipeline

Open `.azuredevops/pipelines/playwright-tests.yml` in VS Code. This pipeline
automates the entire test cycle on every code change:

```yaml
trigger:
  branches:
    include:
      - main

pr:
  branches:
    include:
      - main

pool:
  vmImage: 'ubuntu-latest'

steps:
  - task: NodeTool@0
    inputs:
      versionSpec: '20.x'
    displayName: 'Install Node.js'

  - task: PowerShell@2
    inputs:
      targetType: 'filePath'
      filePath: 'scripts/run-tests.ps1'
      pwsh: true
    displayName: 'Run Playwright tests'

  - task: PublishTestResults@2
    condition: succeededOrFailed()
    inputs:
      testResultsFormat: 'JUnit'
      testResultsFiles: 'playwright-tests/test-results/junit.xml'
      failTaskOnFailedTests: true
    displayName: 'Publish test results'

  - task: PublishPipelineArtifact@1
    condition: succeededOrFailed()
    inputs:
      targetPath: 'playwright-tests/playwright-report'
      artifact: 'playwright-report'
    displayName: 'Publish Playwright HTML report'

  - task: PublishPipelineArtifact@1
    condition: succeededOrFailed()
    inputs:
      targetPath: 'playwright-tests/test-results'
      artifact: 'test-results-screenshots'
    displayName: 'Publish test result screenshots'
```

Key sections to understand:

* **Trigger events** (`trigger`, `pr`): The pipeline runs on every push to `main` and
  on every pull request targeting `main`.
* **Agent pool** (`pool.vmImage`): Tests execute on a fresh Microsoft-hosted Ubuntu
  agent.
* **Node.js setup** (`NodeTool@0`): Installs Node.js 20 on the agent.
* **Test execution** (`PowerShell@2`): Runs `scripts/run-tests.ps1`, the same script
  used locally. It installs npm dependencies and Playwright browsers on first run,
  then executes `npx playwright test` with screenshots enabled for every test.
* **Test results** (`PublishTestResults@2`): Publishes the JUnit XML report so pass/fail
  counts and durations appear in the pipeline's **Tests** tab. `failTaskOnFailedTests`
  marks the pipeline run as failed when any test fails.
* **Artifact publishing** (`PublishPipelineArtifact@1`): Saves the HTML report and raw
  screenshots regardless of test outcome (`condition: succeededOrFailed()`), so both
  are available for download after the run.

### Exercise 2: Create the Pipeline in Azure DevOps

If the pipeline has not been created yet in your Azure DevOps project:

1. Open your project in Azure DevOps and select **Pipelines** > **New pipeline**.
2. Choose the location of your code (Azure Repos Git or GitHub).
3. Select your repository.
4. Choose **Existing Azure Pipelines YAML file**.
5. Select the branch (`main`) and path
   `/.azuredevops/pipelines/playwright-tests.yml`.
6. Review the YAML preview, then select **Run** to save and queue the first run.

### Exercise 3: Push a Change

Make a small modification to verify the pipeline triggers correctly. Add a
`console.log` statement to any test:

```typescript
test('navigate to Ontario.ca search page', async ({ page }) => {
  console.log('CI pipeline verification');
  await page.goto('/search?query=driver+licence');
  await expect(page).toHaveTitle(/ontario/i);
});
```

Commit and push the change:

```bash
git add .
git commit -m "test: add console.log for CI verification"
git push
```

### Exercise 4: Watch the Pipeline

1. Open your project in Azure DevOps and select **Pipelines**.
2. Find the run triggered by your push.
3. Select the run to watch each stage execute in real time.

The pipeline progresses through Node.js setup, test execution, test results
publishing, and artifact upload. Each step shows its own log output.

### Exercise 5: View Results

After the pipeline completes:

1. Check the overall status: green checkmark (passed) or red X (failed).
2. Select the **Tests** tab to see pass/fail counts, durations, and failure details
   sourced from the JUnit report.
3. Select the **Artifacts** dropdown near the top of the run and download the
   `playwright-report` or `test-results-screenshots` artifact.

### Exercise 6: View HTML Report

1. Extract the downloaded `playwright-report` ZIP file.
2. Open `index.html` in a browser.
3. Explore the interactive report: test names, durations, pass/fail status, and
   screenshots for every test (enabled by `PLAYWRIGHT_SCREENSHOT=on` in
   `run-tests.ps1`).

This report is the same one generated locally when running `npx playwright test`, but
now it is produced automatically on every pipeline run.

### Exercise 7: Discussion

Consider these pipeline strategies with your team:

* **Branch policy**: Add a build validation branch policy on `main` that requires this
  pipeline to pass before a pull request can be completed. This prevents regressions
  from reaching the main branch.
* **Nightly schedule**: Add a `schedules` trigger (`cron: '0 2 * * *'`) to catch
  issues from external dependencies or site changes overnight.
* **Environment matrix**: Run tests across multiple browsers (Chromium, Firefox,
  WebKit) using a pipeline matrix strategy to verify cross-browser compatibility.

## Verification Checkpoint

The Azure DevOps pipeline has run successfully. Test results appear in the **Tests**
tab and the `playwright-report` and `test-results-screenshots` artifacts are available
for download.

## Summary

CI/CD pipelines ensure tests run consistently on every code change without manual
intervention. The pipeline automates browser installation, test execution, and report
generation in a clean environment, catching regressions before they reach production.

## Workshop Complete

Congratulations on completing the Playwright 101 workshop! Here is a recap of what
you accomplished:

* **Lab 00**: Set up your development environment with Node.js, VS Code, and
  Playwright
* **Lab 01**: Translated user stories into structured test scenarios
* **Lab 02**: Wrote and ran Playwright tests against a live web application
* **Lab 03**: Used GitHub Copilot to accelerate test authoring and learned the
  two-prompt technique
* **Lab 04**: Automated test execution with an Azure DevOps CI/CD pipeline

### Resources for Further Learning

* [Playwright Documentation](https://playwright.dev)
* [Microsoft Learn: End-to-end testing with Playwright](https://learn.microsoft.com/en-us/training/modules/build-with-playwright/)
* [Azure Pipelines Documentation](https://learn.microsoft.com/en-us/azure/devops/pipelines/)
* [Azure Test Plans](https://learn.microsoft.com/en-us/azure/devops/test/overview)
