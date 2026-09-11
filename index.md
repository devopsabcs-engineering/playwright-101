---
layout: default
title: Home
nav_order: 1
description: "Playwright 101 — From User Stories to Automated Tests"
permalink: /
---

## Playwright 101 Workshop

From User Stories to Automated Tests with Playwright, GitHub Copilot & Azure DevOps
{: .fs-6 .fw-300 }

## Workshop Overview

This hands-on workshop guides manual QA professionals through the transition from
manual testing to browser automation with Playwright. You will start with user stories,
translate them into structured test cases, and then implement those tests using
Microsoft's open-source end-to-end testing framework.

Along the way, you will use GitHub Copilot to accelerate test authoring and learn how
AI-assisted development fits into a modern testing workflow. Choose GitHub Actions
or Azure DevOps in Lab 04 to run functional and accessibility suites in parallel.
Lab 05 extends the workshop with axe accessibility scans, failure investigation,
and manual checks.

No prior automation experience is required. The core workshop takes approximately
one hour with either CI lab. Add 20 minutes for the accessibility extension.

## Workshop Modules

| Module | Title | Duration | Description |
| --- | --- | --- | --- |
| Lab 00 | [Prerequisites](labs/lab-00-prerequisites/) | Pre-workshop | Environment setup |
| Lab 01 | [From User Stories to Test Cases](labs/lab-01-test-planning/) | 10 min | Map requirements to tests |
| Lab 02 | [Your First Playwright Test](labs/lab-02-playwright-basics/) | 20 min | Hands-on test authoring |
| Lab 03 | [GitHub Copilot for Testing](labs/lab-03-copilot-testing/) | 15 min | AI-assisted test generation |
| Lab 04 | [CI/CD Pipeline (GitHub Actions)](labs/lab-04-ci-pipeline/) | 15 min | Automated test execution |
| Lab 04 | [CI/CD Pipeline (Azure DevOps)](labs/lab-04-ci-pipeline-ado/) | 15 min | Automated test execution |
| Lab 05 | [Accessibility Testing](labs/lab-05-accessibility/) | 20 min (extension) | axe scans, parallel CI results, and manual checks |

## Target Application

All labs use the Ontario.ca search page (`https://www.ontario.ca/search`) as the
system under test. This publicly accessible React single-page application provides
rich interactive elements (search input, filters, pagination, dynamic results) without
requiring authentication or special access. Every participant tests against the same
live environment, which keeps setup minimal and results consistent.

## Quick Start

Clone the repository, install dependencies, and verify your environment:

```bash
git clone https://github.com/devopsabcs-engineering/playwright-101.git
cd playwright-101/playwright-tests
npm install
npx playwright install --with-deps chromium
npx playwright test
```

The default command runs functional tests only. Run `npm run test:accessibility`
for axe scans, then use
`npx playwright show-report playwright-report/accessibility` to inspect their report.
The live site may change or have accessibility violations. For setup failures,
review [Prerequisites](labs/lab-00-prerequisites/); for scan findings, use
[Lab 05](labs/lab-05-accessibility/).
