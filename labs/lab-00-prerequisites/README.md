---
layout: default
title: "Lab 00: Prerequisites"
nav_order: 2
description: "Set up your development environment for the Playwright 101 workshop"
permalink: /labs/lab-00-prerequisites/
---

| | |
|---|---|
| **Duration** | 15 minutes (self-paced) |
| **Level** | Beginner |
| **Type** | Setup |

## Learning Objectives

After completing this lab, you will have a fully configured development environment
for writing and running Playwright tests throughout the workshop.

## Prerequisites

* Windows, macOS, or Linux operating system
* Internet access
* A GitHub account (free tier is sufficient)

## Exercises

### Exercise 1: Install Node.js 20+

Download and install Node.js version 20 or later from [nodejs.org](https://nodejs.org).
The LTS (Long Term Support) version is recommended. Verify the installation by running:

```bash
node --version
```

The output should display `v20.x.x` or higher.

### Exercise 2: Install Visual Studio Code

Download and install Visual Studio Code from
[code.visualstudio.com](https://code.visualstudio.com). This serves as your primary
editor for writing tests and interacting with GitHub Copilot.

### Exercise 3: Install VS Code Extensions

Open VS Code and install the following extensions from the Extensions marketplace:

1. **Playwright Test for VS Code** — provides integrated test runner, debugging, and
   code generation directly in the editor
2. **GitHub Copilot** — enables AI-assisted test authoring used in Lab 03

> [!TIP]
> Search for each extension by name in the Extensions sidebar (`Ctrl+Shift+X`) and
> select **Install**.

### Exercise 4: Clone the Repository

Open a terminal and clone the workshop repository:

```bash
git clone https://github.com/devopsabcs-engineering/playwright-101.git
```

### Exercise 5: Install Dependencies

Navigate to the test project directory and install the Node.js dependencies:

```bash
cd playwright-101/playwright-tests
npm install
```

### Exercise 6: Install Playwright Browsers

Playwright requires browser binaries to execute tests. Install the Chromium browser
with its system dependencies:

```bash
npx playwright install --with-deps chromium
```

### Exercise 7: Verify Setup

Run the test suite to confirm everything is configured correctly:

```bash
npx playwright test
```

All tests should pass. A successful run produces output showing each test with a green
checkmark.

## Verification Checkpoint

All 7 Playwright tests pass in the terminal. If any test fails, review the exercises
above and confirm each step completed successfully.

## Summary

Your development environment is ready for the workshop. You have Node.js, VS Code
with the required extensions, Playwright browsers, and a passing test suite.

## Next Steps

Proceed to [Lab 01: From User Stories to Test Cases](../lab-01-test-planning/).
