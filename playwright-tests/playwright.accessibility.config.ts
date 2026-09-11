import { defineConfig } from '@playwright/test';
import baseConfig from './playwright.config';

export default defineConfig(baseConfig, {
  testDir: './accessibility-tests',
  timeout: 60000,
  outputDir: './test-results/accessibility',
  reporter: [
    ['list'],
    ['html', { outputFolder: 'playwright-report/accessibility', open: 'never' }],
    ['junit', { outputFile: 'test-results/accessibility/junit.xml' }],
  ],
});