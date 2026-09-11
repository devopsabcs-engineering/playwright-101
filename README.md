---
title: "Playwright 101 Workshop"
description: "From User Stories to Automated Tests with Playwright, GitHub Copilot & Azure DevOps"
ms.date: 2026-09-11
---

**From User Stories to Automated Tests with Playwright, GitHub Copilot & Azure DevOps**

[![Playwright Tests](https://github.com/devopsabcs-engineering/playwright-101/actions/workflows/playwright-tests.yml/badge.svg)](https://github.com/devopsabcs-engineering/playwright-101/actions/workflows/playwright-tests.yml)
[![GitHub Pages](https://img.shields.io/badge/Workshop_Site-GitHub_Pages-blue)](https://devopsabcs-engineering.github.io/playwright-101/)

This hands-on workshop guides manual QA professionals through the transition to automated testing with Playwright. In approximately one hour, participants move from writing user stories and acceptance criteria to generating, running, and maintaining automated browser tests. The workshop integrates GitHub Copilot for AI-assisted test generation and Azure DevOps for continuous integration pipelines.

Choose GitHub Actions or Azure DevOps for CI. Both run functional and accessibility
suites in parallel. An optional 20-minute accessibility lab extends the core workshop
with axe scans, report triage, and manual checks.

## Quick Start

```bash
git clone https://github.com/devopsabcs-engineering/playwright-101.git
cd playwright-101/playwright-tests
npm install
npx playwright install
npx playwright test
```

To run accessibility checks and view their report from `playwright-tests`:

```bash
npm run test:accessibility
npx playwright show-report playwright-report/accessibility
```

The default test command runs only functional tests. Live-site failures require
investigation; passing automated scans do not establish WCAG conformance.

## Workshop Site

Access the full workshop content at [devopsabcs-engineering.github.io/playwright-101](https://devopsabcs-engineering.github.io/playwright-101/).

## Workshop Modules

| Module | Duration | Description |
|--------|----------|-------------|
| Lab 00: Environment Setup | 10 min | Install Node.js, VS Code, Playwright extension, and GitHub Copilot |
| Lab 01: User Stories & Test Cases | 10 min | Write user stories with acceptance criteria and derive test cases |
| Lab 02: First Playwright Tests | 15 min | Generate and run browser tests against a live site |
| Lab 03: GitHub Copilot for Testing | 10 min | Use AI-assisted test generation and refactoring |
| [Lab 04: CI/CD with GitHub Actions](labs/lab-04-ci-pipeline/) | 15 min | Run functional and accessibility suites in parallel |
| [Lab 04: CI/CD with Azure DevOps](labs/lab-04-ci-pipeline-ado/) | 15 min | Alternative CI platform with parallel suites |
| [Lab 05: Accessibility Testing](labs/lab-05-accessibility/) | 20 min (extension) | Run axe scans, triage findings, and add manual checks |

## Prerequisites

- Node.js 20 or later
- Visual Studio Code with Playwright Test extension
- GitHub Copilot subscription (for Lab 03)
- GitHub or Azure DevOps pipeline access (for your chosen Lab 04)
- Git

## License

This project is licensed under the [MIT License](LICENSE).
