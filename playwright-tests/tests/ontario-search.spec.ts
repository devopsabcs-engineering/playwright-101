import { test, expect } from '@playwright/test';

test.describe('Ontario.ca Search', () => {

  test.beforeEach(async ({ context }) => {
    // Skip language splash page by setting English cookie
    await context.addCookies([{
      name: 'lang',
      value: 'en',
      domain: '.ontario.ca',
      path: '/'
    }]);
  });

  test('navigate to Ontario.ca search page', async ({ page }) => {
    // Scenario 1: Basic Navigation — page.goto(), toHaveTitle()
    console.log('CI pipeline verification');
    await page.goto('/search/search-results/?query=health+card');
    await expect(page).toHaveTitle(/ontario/i);
  });

test('search for health card returns results', async ({ page }) => {
  await page.goto('/search?query=health+card');

  await expect(page).toHaveTitle(/ontario/i);

  const firstResult = page.getByRole('link', {
    name: /Apply for OHIP and get a/i
  });

  await expect(firstResult).toBeVisible();

  await expect(firstResult).toContainText(/OHIP/i);
});

test('filter by topic narrows results', async ({ page }) => {
  await page.goto('/search?query=health+card');

  const drivingFilter = page.getByRole('checkbox', {
    name: 'Driving and road safety'
  });

  await drivingFilter.check();

  await page.getByRole('button', { name: 'Apply' }).click();

  await expect(drivingFilter).toBeChecked();
});

test('sort results by updated date', async ({ page }) => {
  await page.goto('/search?query=health+card');

  const updatedDate = page.getByRole('radio', {
    name: 'Updated date (new to old)'
  });

  await updatedDate.check();

  await page.getByRole('button', { name: 'Apply' }).click();

  await expect(updatedDate).toBeChecked();
});

test('pagination navigates to next page', async ({ page }) => {
  await page.goto('/search?query=health+card');

  await page
    .getByRole('button', { name: 'Go to page 2', exact: true })
    .click();

  await expect(
    page.getByRole('button', { name: 'Go to page 2', exact: true })
  ).toBeVisible();
});

test('search with no results shows empty state', async ({ page }) => {
  await page.goto('/search?query=health+card');

  const searchInput = page.getByRole('combobox', { name: 'Search' });

  await searchInput.fill('fgfjyhgdf');

  await page.getByRole('button', { name: 'Submit' }).click();

  // We still need the current empty-state locator here
});

  test('intentional failure: expects the wrong government page title @failure-demo', async ({ page }) => {
    await page.goto('/search/search-results/?query=health+card');
    await expect(page).toHaveTitle(/ontario/i);

    await expect(
      page,
      'Intentional demo error: Ontario.ca is not the Government of Canada website'
    ).toHaveTitle(/Government of Canada/i);
  });

  test('intentional failure: expects the old query after editing search @failure-demo', async ({ page }) => {
    await page.goto('/search/search-results/?query=driver+licence');
    const searchInput = page.getByRole('combobox', { name: 'Search' });
    await expect(searchInput).toBeVisible();
    await searchInput.fill('health card');

    await expect(
      searchInput,
      'Intentional demo error: the search value changed to health card, but the test expects the old query'
    ).toHaveValue('driver licence');
  });

test('search input field is visible and functional', async ({ page }) => {
  await page.goto('/search?query=driver+licence');

  const searchInput = page.getByRole('combobox', { name: 'Search' });

  await expect(searchInput).toBeVisible();

  await searchInput.clear();
  await searchInput.fill('health card');
  await searchInput.press('Enter');

  const firstResult = page.getByRole('link', {
    name: /Apply for OHIP and get a/i
  });

  await expect(firstResult).toBeVisible();
});

test('filter by topic decreases the result count', async ({ page }) => {
  await page.goto('/search?query=health+card');

  const resultsHeading = page
    .getByRole('heading', { level: 2 })
    .filter({ hasText: /\d[\d,]* results? for/i });

  const readResultCount = async () => {
    const headingText = await resultsHeading.innerText();
    const match = headingText.match(/^([\d,]+)\s+results?\b/i);

    expect(
      match,
      `Could not read result count from: ${headingText}`
    ).not.toBeNull();

    return Number(match![1].replace(/,/g, ''));
  };

  const initialCount = await readResultCount();

  await page
    .getByRole('checkbox', { name: 'Driving and road safety' })
    .check();

  await page.getByRole('button', { name: 'Apply' }).click();

  await expect.poll(readResultCount).toBeLessThan(initialCount);
});



}
// Test that clicking a search result navigates to the correct page

);
