---
layout: default
title: "Lab 05: Accessibility Testing"
nav_order: 8
description: "Run axe accessibility scans with Playwright, investigate WCAG findings, and review parallel CI results"
permalink: /labs/lab-05-accessibility/
---

| | |
| --- | --- |
| **Duration** | 20 minutes (extension to the one-hour workshop) |
| **Level** | Beginner |
| **Type** | Hands-on + Report Review |

## Learning Objectives

* Run functional and accessibility suites separately
* Scan rendered page states with axe rules tagged for WCAG 2.1 Level A and AA
* Investigate violations using rule IDs, affected elements, and report attachments
* Review independent CI jobs and identify checks that require manual testing

## Prerequisites

* Complete Lab 02 and either [GitHub Actions](../lab-04-ci-pipeline/) or
  [Azure DevOps](../lab-04-ci-pipeline-ado/) for the CI exercise.
* Install Node.js 20 or later and Chromium using the commands below.
* Have network access to Ontario.ca. No account is required for the test pages.

> [!IMPORTANT]
> Automated scans find some accessibility issues, not every WCAG requirement.
> A passing scan is not proof of WCAG conformance or legal compliance. Keyboard,
> screen-reader, zoom, and other manual checks remain necessary.

## Exercises

### Exercise 1: Run the Accessibility Suite

From the repository root:

```bash
cd playwright-tests
npm ci
npx playwright install --with-deps chromium
npm run test:accessibility
```

The project already includes `@axe-core/playwright`. The accessibility command
uses [playwright.accessibility.config.ts](https://github.com/devopsabcs-engineering/playwright-101/blob/main/playwright-tests/playwright.accessibility.config.ts),
which inherits the base URL, Chromium project, screenshot setting, and retry trace
setting from the functional config. It changes the test directory, timeout, and
report paths.

Compare the two suites:

| Suite | Command | Test directory | HTML report | JUnit XML |
| --- | --- | --- | --- | --- |
| Functional | `npm run test:functional` | `tests` | `playwright-report` | `test-results/junit.xml` |
| Accessibility | `npm run test:accessibility` | `accessibility-tests` | `playwright-report/accessibility` | `test-results/accessibility/junit.xml` |

`npm test` and `npx playwright test` select the default functional config; they do
not run both suites. To compare locally, run functional tests first, then
accessibility tests. The accessibility outputs are nested under the functional
output directories, so a later functional run can clear earlier accessibility
outputs. CI avoids collisions by running each suite on a separate runner.

### Exercise 2: Read the Scan

Open [ontario-accessibility.spec.ts](https://github.com/devopsabcs-engineering/playwright-101/blob/main/playwright-tests/accessibility-tests/ontario-accessibility.spec.ts).
Find the three scenarios:

| Page state | Readiness check before scanning |
| --- | --- |
| English home page | Level-one heading is visible |
| Populated search results | First result link is visible |
| Empty search results | Heading containing `0 results` is visible |

The English language cookie avoids the language selection page. Each readiness
assertion ensures the intended page state has rendered before axe inspects it.
The scan uses this chain:

```typescript
const results = await new AxeBuilder({ page })
  .withTags(['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa'])
  .analyze();
```

The tags include relevant WCAG 2.0 and 2.1 Level A and AA rules. They do not enable
every axe rule or every WCAG success criterion. The test attaches the full result
as `axe-results` JSON before asserting that the violation list is empty.

### Exercise 3: Inspect and Triage Results

Open the accessibility HTML report from `playwright-tests`:

```bash
npx playwright show-report playwright-report/accessibility
```

1. Select a test and inspect its status, screenshot, and `axe-results` attachment.
   Screenshots are captured on failure locally by default; CI captures every test.
2. For a violation, record the rule ID, impact, help URL, affected `target`
   selectors, and `failureSummary` from the assertion or JSON attachment.
3. Inspect the affected element in the page. Distinguish a site issue from a
   navigation or readiness failure that prevented the scan from running.
4. Review axe's `incomplete` results for checks that need human judgment. The
   current assertion fails on `violations`, not on `incomplete` results.
5. Re-run one scenario to verify the finding:

```bash
npm run test:accessibility -- --grep "populated search results"
```

If the scan passes, inspect its `passes` and `incomplete` entries and describe one
rule it checked. Do not manufacture a failure in the live site.

Ontario.ca is a public site outside this repository's control. Report findings
with reproducible steps and evidence; do not disable rules or exclude affected
elements just to obtain a green run. On an application you own, fix the underlying
markup or interaction and repeat the scan.

### Exercise 4: Compare Parallel CI Results

Open a workflow or pipeline run from Lab 04:

* In GitHub Actions, inspect **Playwright functional** and **Playwright
  accessibility**, including each job's summary. `fail-fast: false` prevents a
  failure in one matrix job from cancelling the other.
* In Azure DevOps, inspect the **Functional** and **Accessibility** jobs and the
  **Tests** tab with separate `Playwright functional` and `Playwright accessibility`
  test runs. Available parallel-job capacity determines whether both start at once.

Both platforms publish the same artifact names:

| Suite | HTML report | Raw results |
| --- | --- | --- |
| Functional | `playwright-report-functional` | `test-results-functional` |
| Accessibility | `playwright-report-accessibility` | `test-results-accessibility` |

Download the accessibility HTML artifact, extract it, and run
`npx playwright show-report <extracted-report-directory>`. Check the axe attachment.
Raw results include JUnit XML, screenshots, and traces when generated. Traces are
recorded on the first retry, so successful first attempts do not have one.

A functional pass and an accessibility failure are independent findings. Both
suites must pass for the CI run to be green. Branch protection or an ADO build
validation policy must be configured separately to make CI a merge gate.

The functional suite contains intentional `@failure-demo` tests. Identify these
separately from genuine failures when reviewing the run; they do not cancel the
accessibility job.

### Exercise 5: Add Manual Coverage

On the search page, perform these checks and record expected versus actual behavior:

* Navigate with Tab and Shift+Tab. Check focus visibility, logical order, and the
  absence of keyboard traps.
* Submit a search with the keyboard and confirm you can reach the results.
* Use a screen reader to review the input's accessible name, headings, landmarks,
  and announcements when results change.
* Check text at 200% zoom and reflow at a 320 CSS-pixel viewport (often 400% zoom
  on a 1280-pixel-wide viewport). Look for lost content or controls.

For ADO traceability, map each acceptance criterion to at least one Test Case in a
static Test Suite under a Test Plan. Reference the AC identifier, link the Test
Case to the User Story using `Tests`, and verify the reverse `Tested By` link.
Apply the `Agentic AI` tag to the plan, suite, and cases. A CI JUnit run alone does
not create this acceptance-criteria coverage.

## Verification Checkpoint

* All three accessibility scenarios execute, or you identify the specific
  environment or page-readiness blocker.
* You can locate the accessibility HTML report, JUnit XML, and axe attachment.
* You explain one scan result and one check requiring manual review.
* Both CI suites publish independent results, including evidence of failures.

## Resources

* [Playwright accessibility testing](https://playwright.dev/docs/accessibility-testing)
* [axe-core Playwright integration](https://www.npmjs.com/package/@axe-core/playwright)
* [WCAG 2.1](https://www.w3.org/TR/WCAG21/)
* [WAI Easy Checks](https://www.w3.org/WAI/test-evaluate/easy-checks/)
