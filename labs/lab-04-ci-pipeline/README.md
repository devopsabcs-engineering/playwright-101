---
layout: default
title: "Lab 04: CI/CD Pipeline"
nav_order: 6
description: "Run functional and accessibility Playwright tests in parallel with GitHub Actions"
permalink: /labs/lab-04-ci-pipeline/
---

| | |
| --- | --- |
| **Duration** | 15 minutes |
| **Level** | Beginner |
| **Type** | Demo + Configuration |

## Learning Objectives

After completing this lab, you will be able to:

* Understand CI/CD pipeline concepts for test automation
* Read and modify a GitHub Actions workflow
* Run functional and accessibility suites as independent matrix jobs
* View test results and artifacts in GitHub
* Decide when to run tests (push, PR, schedule)

## Prerequisites

* Lab 03 completed
* Push access to the GitHub repository

## Exercises

### Exercise 1: Review the Workflow

Open [.github/workflows/playwright-tests.yml](https://github.com/devopsabcs-engineering/playwright-101/blob/main/.github/workflows/playwright-tests.yml)
in VS Code. It runs on pushes and pull requests targeting `main`, and supports
manual runs through **Run workflow**. Focus on this matrix from the full workflow:

{% raw %}

```yaml
jobs:
  test:
    name: Playwright ${{ matrix.suite }}
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      max-parallel: 2
      matrix:
        include:
          - suite: functional
            junitPath: test-results/junit.xml
            reportPath: playwright-report
            resultsPath: test-results
          - suite: accessibility
            junitPath: test-results/accessibility/junit.xml
            reportPath: playwright-report/accessibility
            resultsPath: test-results/accessibility
```

Each matrix entry gets its own Ubuntu runner. With `max-parallel: 2`, both suites
can run concurrently when runner capacity is available. `fail-fast: false` lets
one suite finish even if the other fails. Neither suite depends on the other.

Read the steps below the matrix in the full workflow:

* Checkout and Node.js 20 setup prepare each runner.
* `npm ci` installs locked dependencies in `playwright-tests`.
* `npx playwright install --with-deps chromium` installs the browser.
* `npm run test:${{ matrix.suite }}` selects the functional or accessibility config.
* `PLAYWRIGHT_SCREENSHOT: 'on'` captures screenshots for every test; the shared
  config records traces on the first retry.
* The summary script reads `JUNIT_PATH` from the matrix and writes counts and
  test details to that job's GitHub summary. A missing JUnit file fails this step.
* Upload steps use `if: always()` to retain each suite's HTML report, JUnit XML,
  screenshots, and traces even when tests fail, provided those files were generated.
  Missing artifact paths fail the upload step. Retention is 30 days.

{% endraw %}

### Exercise 2: Push a Change

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
User Story or Bug ID, linked to a Feature and Epic, and open a PR targeting `main`:

```bash
git add playwright-tests/tests/ontario-search.spec.ts
git commit -m "test: verify parallel CI suites AB#1234"
git push -u origin HEAD
```

Alternatively, select **Actions > Playwright Tests > Run workflow** to run the
workflow on `main` without changing a test once the workflow is merged.

### Exercise 3: Watch the Pipeline

1. Open your repository on GitHub.
2. Select the **Actions** tab.
3. Find the workflow run triggered by your PR or manual dispatch.
4. Check both **Playwright functional** and **Playwright accessibility** jobs.
5. Select each job to watch its steps and logs independently.

The workflow progresses through checkout, dependency installation, browser setup, test
execution, and artifact upload. Each step shows its own log output.

### Exercise 4: View Results

After the workflow completes:

1. Check the overall status: green checkmark (passed) or red X (failed).
2. Read each job's summary for its own test counts and failures.
3. Scroll to **Artifacts** and find all four suite-specific artifacts:

| Suite | HTML report | JUnit, screenshots, and traces |
| --- | --- | --- |
| Functional | `playwright-report-functional` | `test-results-functional` |
| Accessibility | `playwright-report-accessibility` | `test-results-accessibility` |

### Exercise 5: View HTML Report

1. Download and extract one of the HTML report artifacts.
2. From `playwright-tests`, run `npx playwright show-report <extracted-report-directory>`.
3. Explore the interactive report: test names, durations, pass/fail status, and
   screenshots for failed tests (when configured).

These reports match local runs with `npm run test:functional` and
`npm run test:accessibility`. Each job's report contains only its own suite.

### Exercise 6: Discussion

Consider these pipeline strategies with your team:

* Require both suite checks in a branch protection rule or ruleset on `main`.
  Running a workflow alone does not block merges.
* Add a nightly `schedule` trigger to catch changes to the external site.
* Extend the matrix to other browsers only after adding their projects and
  browser installation steps.

## Verification Checkpoint

Both matrix jobs finish, each has a summary, and all four artifacts are available
when tests execute. If the live site produces failures, identify the failing suite
and inspect its report rather than treating an expected green status as evidence.

The functional suite includes intentional `@failure-demo` tests for practicing
failure investigation. These can make the functional job red even when normal
scenarios pass; the accessibility job should still complete independently.

## Summary

CI/CD pipelines ensure tests run consistently on every code change without manual
intervention. The workflow automates browser installation, test execution, and report
generation in a clean environment, catching regressions before they reach production.

## Next Steps

Continue with [Lab 05: Accessibility Testing](../lab-05-accessibility/) to explore
the axe scans, diagnose violations, and practice manual checks. This optional
20-minute extension follows the one-hour core workshop.

### Resources for Further Learning

* [Playwright Documentation](https://playwright.dev)
* [Microsoft Learn: End-to-end testing with Playwright](https://learn.microsoft.com/en-us/training/modules/build-with-playwright/)
* [GitHub Actions Documentation](https://docs.github.com/en/actions)
* [Azure Test Plans](https://learn.microsoft.com/en-us/azure/devops/test/overview)
