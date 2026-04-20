---
layout: default
title: "Lab 04: CI/CD Pipeline"
nav_order: 6
description: "Automate Playwright tests with GitHub Actions"
permalink: /labs/lab-04-ci-pipeline/
---

| | |
|---|---|
| **Duration** | 15 minutes |
| **Level** | Beginner |
| **Type** | Demo + Configuration |

## Learning Objectives

After completing this lab, you will be able to:

* Understand CI/CD pipeline concepts for test automation
* Read and modify a GitHub Actions workflow
* View test results and artifacts in GitHub
* Decide when to run tests (push, PR, schedule)

## Prerequisites

* Lab 03 completed
* Push access to the GitHub repository

## Exercises

### Exercise 1: Review the Workflow

Open `.github/workflows/playwright-tests.yml` in VS Code. This workflow automates
the entire test cycle on every code change. Walk through each section:

```yaml
name: Playwright Tests
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
jobs:
  test:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: playwright-tests
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      - name: Install dependencies
        run: npm ci
      - name: Install Playwright browsers
        run: npx playwright install --with-deps chromium
      - name: Run Playwright tests
        run: npx playwright test
      - name: Upload test report
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: playwright-report
          path: playwright-tests/playwright-report/
          retention-days: 30
```

Key sections to understand:

* **Trigger events** (`on`): The workflow runs on every push to `main` and on every
  pull request targeting `main`.
* **Job configuration** (`runs-on`, `working-directory`): Tests execute on a fresh
  Ubuntu runner with the working directory set to `playwright-tests`.
* **Checkout and setup**: `actions/checkout@v4` clones the repository,
  `actions/setup-node@v4` installs Node.js 20.
* **Dependency installation**: `npm ci` installs exact versions from the lockfile for
  reproducible builds.
* **Browser installation**: `npx playwright install --with-deps chromium` downloads
  the Chromium browser binary and its system dependencies.
* **Test execution**: `npx playwright test` runs the full test suite.
* **Artifact upload**: `actions/upload-artifact@v4` saves the HTML report regardless
  of test outcome (`if: always()`). The report is retained for 30 days.

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

Commit and push the change:

```bash
git add .
git commit -m "test: add console.log for CI verification"
git push
```

### Exercise 3: Watch the Pipeline

1. Open your repository on GitHub.
2. Select the **Actions** tab.
3. Find the workflow run triggered by your push.
4. Select the run to watch each step execute in real time.

The workflow progresses through checkout, dependency installation, browser setup, test
execution, and artifact upload. Each step shows its own log output.

### Exercise 4: View Results

After the workflow completes:

1. Check the overall status: green checkmark (passed) or red X (failed).
2. Scroll to the **Artifacts** section at the bottom of the workflow run.
3. Download the `playwright-report` artifact.

### Exercise 5: View HTML Report

1. Extract the downloaded ZIP file.
2. Open `index.html` in a browser.
3. Explore the interactive report: test names, durations, pass/fail status, and
   screenshots for failed tests (when configured).

This report is the same one generated locally when running `npx playwright test`, but
now it is produced automatically on every pipeline run.

### Exercise 6: Discussion

Consider these pipeline strategies with your team:

* **Quality gate**: Run tests on every pull request and block merging when tests fail.
  This prevents regressions from reaching the main branch.
* **Nightly schedule**: Add a cron trigger (`schedule: - cron: '0 2 * * *'`) to catch
  issues from external dependencies or site changes overnight.
* **Environment matrix**: Run tests across multiple browsers (Chromium, Firefox,
  WebKit) using a GitHub Actions matrix strategy to verify cross-browser
  compatibility.

## Verification Checkpoint

The GitHub Actions workflow has run successfully. Test results appear in the Actions
tab and the `playwright-report` artifact is available for download.

## Summary

CI/CD pipelines ensure tests run consistently on every code change without manual
intervention. The workflow automates browser installation, test execution, and report
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
* **Lab 04**: Automated test execution with a GitHub Actions CI/CD pipeline

### Resources for Further Learning

* [Playwright Documentation](https://playwright.dev)
* [Microsoft Learn: End-to-end testing with Playwright](https://learn.microsoft.com/en-us/training/modules/build-with-playwright/)
* [GitHub Actions Documentation](https://docs.github.com/en/actions)
* [Azure Test Plans](https://learn.microsoft.com/en-us/azure/devops/test/overview)
