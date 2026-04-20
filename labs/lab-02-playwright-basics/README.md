---
layout: default
title: "Lab 02: Your First Playwright Test"
nav_order: 4
description: "Run, explore, and modify Playwright tests hands-on"
permalink: /labs/lab-02-playwright-basics/
---

| | |
|---|---|
| **Duration** | 20 minutes |
| **Level** | Beginner |
| **Type** | Hands-on |

## Learning Objectives

After completing this lab, you will be able to:

* Run existing Playwright tests from the command line
* Understand test structure: `describe`, `test`, `expect`
* Modify tests to change behavior and add assertions
* Use Playwright Codegen to record browser interactions
* Debug failing tests with Trace Viewer

## Prerequisites

* [Lab 00: Prerequisites](../lab-00-prerequisites/) completed
* [Lab 01: From User Stories to Test Cases](../lab-01-test-planning/) reviewed

## Exercises

### Exercise 1: Run the Pre-built Tests

Open a terminal and navigate to the test project directory:

```bash
cd playwright-tests
npx playwright test
```

All 7 tests should pass. The output shows each test name with a green checkmark and
the total execution time. If any test fails, revisit Lab 00 to confirm your setup.

### Exercise 2: Explore Test Structure

Open `tests/ontario-search.spec.ts` in VS Code. This file contains the full test
suite you mapped in Lab 01. Walk through the key structural elements.

**Imports and test grouping**

Every Playwright test file starts with an import and uses `test.describe()` to group
related tests:

```typescript
import { test, expect } from '@playwright/test';

test.describe('Ontario.ca Search', () => {
  // All search-related tests live inside this block
});
```

**Shared setup with beforeEach**

The `test.beforeEach()` hook runs before every test in the group. Here it sets a
cookie to skip the language selection splash page:

```typescript
test.beforeEach(async ({ context }) => {
  await context.addCookies([{
    name: 'lang',
    value: 'en',
    domain: '.ontario.ca',
    path: '/'
  }]);
});
```

**Individual test cases**

Each `test()` block targets one scenario. Notice the `async` function and the
destructured `{ page }` fixture:

```typescript
test('search for driver licence returns results', async ({ page }) => {
  await page.goto('/search?query=driver+licence');
  await page.waitForSelector('h4 a');
  await expect(page.locator('h3').filter({ hasText: /results/ })).toBeVisible();
  await expect(page.locator('h4 a').first()).toBeVisible();
});
```

**Locator strategies**

Playwright provides multiple ways to find elements on a page:

| Strategy | Example | When to Use |
|---|---|---|
| CSS selector | `page.locator('h4 a')` | Targeting elements by tag, class, or ID |
| Filter with regex | `page.locator('h3').filter({ hasText: /results/ })` | Narrowing matches by text content |
| Label text | `page.getByLabel('Updated date (new to old)')` | Accessible form controls |
| Chained locator | `page.locator('label').filter({ hasText: /driving/i }).first()` | Combining strategies for precision |

**Assertions**

Playwright assertions auto-wait for conditions to become true:

| Assertion | Purpose |
|---|---|
| `toHaveTitle(/ontario/i)` | Page title matches a pattern |
| `toBeVisible()` | Element is present and visible |
| `toContainText('2')` | Element contains expected text |

### Exercise 3: Modify a Test

Change the search query in the "search for driver licence returns results" test.
Open `tests/ontario-search.spec.ts` and update the query parameter:

```typescript
test('search for health card returns results', async ({ page }) => {
  await page.goto('/search?query=health+card');
  await page.waitForSelector('h4 a');
  await expect(page.locator('h3').filter({ hasText: /results/ })).toBeVisible();
  await expect(page.locator('h4 a').first()).toBeVisible();
});
```

Run the tests again to verify the modified test passes:

```bash
npx playwright test
```

> [!TIP]
> You changed only the query string and test name. The locator and assertion
> patterns remain the same because the page structure is identical for different
> search terms.

### Exercise 4: Add an Assertion

Strengthen the modified test by asserting that the first result link contains
relevant text. Add this line before the closing `});`:

```typescript
await expect(page.locator('h4 a').first()).toContainText('health');
```

The updated test now verifies three things: results appear, the first link is
visible, and the first link text relates to the search query. Run the tests again
to confirm the new assertion passes.

Assertion specificity is a tradeoff. Broad assertions (`toBeVisible`) are stable
but catch fewer bugs. Narrow assertions (`toContainText('health')`) catch more
issues but may break when content changes. Choose the level of specificity that
matches your confidence in the page content.

### Exercise 5: Use Codegen

Playwright Codegen records your browser interactions and generates test code
automatically. Run the codegen script:

```bash
npm run codegen
```

This opens a Chromium browser pointed at the ontario.ca search page. Perform these
actions:

1. Click the search input field
2. Clear the existing text and type "birth certificate"
3. Press Enter
4. Click on the first search result

As you interact, Codegen writes corresponding Playwright code in a separate window.
Copy the generated code into a new test block in your spec file to see how recorded
actions translate to `locator()` calls and assertions.

> [!NOTE]
> Codegen output is a starting point. Review and refine the generated locators for
> resilience. Prefer `getByLabel()` or `filter({ hasText })` over brittle CSS
> selectors when possible.

### Exercise 6: Debug with Trace Viewer

Trace Viewer captures a timeline of every action in a test run, including
screenshots, DOM snapshots, and network requests. To see it in action, introduce
a deliberate failure.

**Step 1: Force a failure.** In the "search for health card returns results" test,
change the title assertion to expect text that will not match:

```typescript
await expect(page).toHaveTitle(/nonexistent title/i);
```

**Step 2: Run with tracing enabled.**

```bash
npx playwright test --trace on
```

The test fails, and Playwright saves a trace file.

**Step 3: Open Trace Viewer.**

```bash
npx playwright show-trace test-results/*/trace.zip
```

Explore the timeline:

* Each action appears as a step with a before/after screenshot
* Click any step to inspect the DOM snapshot at that moment
* The Network tab shows API calls made during the test
* The Console tab displays browser console output

**Step 4: Revert the change.** Restore the original assertion so the test passes
again:

```typescript
await expect(page).toHaveTitle(/ontario/i);
```

Run `npx playwright test` to confirm all tests pass.

## Verification Checkpoint

Your modified test passes with the new "health card" search query and the additional
`toContainText('health')` assertion. You have used Codegen to record a browser
interaction and Trace Viewer to inspect a failing test.

## Summary

Playwright provides auto-waiting assertions that eliminate manual sleep calls,
multiple locator strategies for finding elements reliably, and Trace Viewer for
visual debugging. These capabilities make tests easier to write, maintain, and
troubleshoot.

## Next Steps

Proceed to [Lab 03: GitHub Copilot for Testing](../lab-03-copilot-testing/).
