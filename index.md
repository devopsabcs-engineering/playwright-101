---
layout: default
title: Home
nav_order: 1
description: "Playwright 101 — From User Stories to Automated Tests"
permalink: /
---

# Playwright 101 Workshop

From User Stories to Automated Tests with Playwright, GitHub Copilot & Azure DevOps
{: .fs-6 .fw-300 }

## Workshop Overview

This hands-on workshop guides manual QA professionals through the transition from
manual testing to browser automation with Playwright. You will start with user stories,
translate them into structured test cases, and then implement those tests using
Microsoft's open-source end-to-end testing framework.

Along the way, you will use GitHub Copilot to accelerate test authoring and learn how
AI-assisted development fits into a modern testing workflow. The final module connects
your tests to an Azure DevOps CI/CD pipeline so they run automatically on every code
change.

No prior automation experience is required. The workshop takes approximately one hour
to complete and covers the full journey from requirement analysis to continuous test
execution in a live pipeline.

## Workshop Modules

| Module | Title | Duration | Description |
|--------|-------|----------|-------------|
| Lab 00 | [Prerequisites](labs/lab-00-prerequisites/) | Pre-workshop | Environment setup |
| Lab 01 | [From User Stories to Test Cases](labs/lab-01-test-planning/) | 10 min | Map requirements to tests |
| Lab 02 | [Your First Playwright Test](labs/lab-02-playwright-basics/) | 20 min | Hands-on test authoring |
| Lab 03 | [GitHub Copilot for Testing](labs/lab-03-copilot-testing/) | 15 min | AI-assisted test generation |
| Lab 04 | [CI/CD Pipeline](labs/lab-04-ci-pipeline/) | 15 min | Automated test execution |

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

All tests should pass on a fresh clone. If any test fails, review the
[Prerequisites](labs/lab-00-prerequisites/) lab for detailed setup instructions.
