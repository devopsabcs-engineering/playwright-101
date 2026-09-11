---
layout: default
title: "Lab 04: CI/CD Pipeline (Azure DevOps)"
nav_order: 7
description: "Run functional and accessibility Playwright tests in parallel with Azure DevOps Pipelines"
permalink: /labs/lab-04-ci-pipeline-ado/
---

| | |
| --- | --- |
| **Duration** | 15 minutes |
| **Level** | Beginner |
| **Type** | Demo + Configuration |

## Learning Objectives

After completing this lab, you will be able to:

* Understand CI/CD pipeline concepts for test automation
* Read and modify an Azure DevOps YAML pipeline
* Run functional and accessibility suites as independent matrix jobs
* Create a pipeline in Azure DevOps from an existing YAML file
* View test results and artifacts in Azure DevOps
* Decide when to run tests (push, PR, schedule)

## Prerequisites

* Lab 03 completed
* An Azure DevOps organization and project
* Push access to the Azure DevOps (or mirrored GitHub) repository

> [!NOTE]
> Choose [GitHub Actions](../lab-04-ci-pipeline/) for the alternative CI lab.
> Azure Pipelines can also build a GitHub repository.

## Exercises

### Exercise 1: Review the Pipeline

Open [.azuredevops/pipelines/playwright-tests.yml](https://github.com/devopsabcs-engineering/playwright-101/blob/main/.azuredevops/pipelines/playwright-tests.yml)
in VS Code. Focus on this matrix from the full pipeline:

```yaml
jobs:
  - job: Playwright
    displayName: 'Playwright tests'
    strategy:
      maxParallel: 2
      matrix:
        Functional:
          suite: 'functional'
          junitPath: 'test-results/junit.xml'
          reportPath: 'playwright-report'
          resultsPath: 'test-results'
        Accessibility:
          suite: 'accessibility'
          junitPath: 'test-results/accessibility/junit.xml'
          reportPath: 'playwright-report/accessibility'
          resultsPath: 'test-results/accessibility'
```

Each matrix entry runs independently on an Ubuntu agent. `maxParallel: 2` allows
both suites to run at once, subject to your organization's parallel-job capacity.
With one available slot, the jobs queue instead of running simultaneously.

Read the steps below the matrix in the full pipeline:

* `UseNode@1` installs Node.js 20; `npm install` installs test dependencies.
* Playwright installs Chromium and its system dependencies.
* `npm run test:$(suite)` selects the functional or accessibility config.
* `PLAYWRIGHT_SCREENSHOT: 'on'` enables screenshots for every test, and the shared
  config records traces on the first retry.
* `PublishTestResults@2` publishes `$(junitPath)` with the title
  `Playwright $(suite)`. Failed tests or missing JUnit results fail this step.
* `PublishPipelineArtifact@1` publishes suite-specific reports and raw results with
  `condition: succeededOrFailed()`, preserving generated evidence after failures.

> [!IMPORTANT]
> The YAML `pr` trigger applies to GitHub repositories. For Azure Repos Git,
> configure a build validation branch policy on `main` to run this pipeline for PRs.
> The `trigger` section runs builds for pushes to `main` in either case.

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

Commit and push from your work-item feature branch. Replace `1234` with your
User Story or Bug ID, linked to a Feature and Epic, then open a PR targeting `main`:

```bash
git add playwright-tests/tests/ontario-search.spec.ts
git commit -m "test: verify parallel CI suites AB#1234"
git push -u origin HEAD
```

### Exercise 4: Watch the Pipeline

1. Open your project in Azure DevOps and select **Pipelines**.
2. Find the run triggered by your PR (with the required trigger or branch policy).
3. Check both **Functional** and **Accessibility** matrix jobs and their logs.

The pipeline progresses through Node.js setup, test execution, test results
publishing, and artifact upload. Each step shows its own log output.

### Exercise 5: View Results

After the pipeline completes:

1. Check the overall status: green checkmark (passed) or red X (failed).
2. Select the **Tests** tab to see pass/fail counts, durations, and failure details
   sourced from the JUnit report.
3. Select **Artifacts** and find both suites' outputs:

| Suite | HTML report | JUnit, screenshots, and traces |
| --- | --- | --- |
| Functional | `playwright-report-functional` | `test-results-functional` |
| Accessibility | `playwright-report-accessibility` | `test-results-accessibility` |

### Exercise 6: View HTML Report

1. Download and extract one of the HTML report artifacts.
2. From `playwright-tests`, run `npx playwright show-report <extracted-report-directory>`.
3. Explore the interactive report: test names, durations, pass/fail status, and
  screenshots for every test (enabled by `PLAYWRIGHT_SCREENSHOT=on` in the pipeline).

These reports match local runs with `npm run test:functional` and
`npm run test:accessibility`. Each job's report contains only its own suite.

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

Both matrix jobs finish, the **Tests** tab contains separate suite runs, and all
four artifacts are available when tests execute. Diagnose failures from the live
site using the corresponding suite's evidence; do not assume all scans will pass.

The functional suite includes intentional `@failure-demo` tests for practicing
failure investigation. These can make the functional job red even when normal
scenarios pass; the accessibility job should still complete independently.

## Summary

CI/CD pipelines ensure tests run consistently on every code change without manual
intervention. The pipeline automates browser installation, test execution, and report
generation in a clean environment, catching regressions before they reach production.

## Next Steps

Continue with [Lab 05: Accessibility Testing](../lab-05-accessibility/) to explore
the axe scans, diagnose violations, and practice manual checks. This optional
20-minute extension follows the one-hour core workshop.

### Resources for Further Learning

* [Playwright Documentation](https://playwright.dev)
* [Microsoft Learn: End-to-end testing with Playwright](https://learn.microsoft.com/en-us/training/modules/build-with-playwright/)
* [Azure Pipelines Documentation](https://learn.microsoft.com/en-us/azure/devops/pipelines/)
* [Azure Test Plans](https://learn.microsoft.com/en-us/azure/devops/test/overview)
