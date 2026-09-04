// Renders the Playwright JUnit results as a Markdown table in the GitHub Actions job summary.
import { readFileSync, existsSync, appendFileSync } from 'node:fs';

const JUNIT_PATH = 'test-results/junit.xml';
const summaryFile = process.env.GITHUB_STEP_SUMMARY;

function writeSummary(markdown) {
  if (summaryFile) {
    appendFileSync(summaryFile, markdown);
  } else {
    console.log(markdown);
  }
}

if (!existsSync(JUNIT_PATH)) {
  writeSummary(`## Playwright Test Results\n\n⚠️ No test results file found at \`${JUNIT_PATH}\`.\n`);
  process.exit(0);
}

const xml = readFileSync(JUNIT_PATH, 'utf8');

const suitesMatch = xml.match(
  /<testsuites[^>]*\btests="(\d+)"[^>]*\bfailures="(\d+)"[^>]*\bskipped="(\d+)"[^>]*\berrors="(\d+)"[^>]*\btime="([\d.]+)"/
);
const [, total = '0', failures = '0', skipped = '0', errors = '0', time = '0'] = suitesMatch ?? [];
const passed = Number(total) - Number(failures) - Number(skipped) - Number(errors);
const status = Number(failures) > 0 || Number(errors) > 0 ? '❌ Failed' : '✅ Passed';

let markdown = `## Playwright Test Results — ${status}\n\n`;
markdown += `| Total | Passed | Failed | Skipped | Errors | Duration |\n`;
markdown += `|-------|--------|--------|---------|--------|----------|\n`;
markdown += `| ${total} | ${passed} | ${failures} | ${skipped} | ${errors} | ${Number(time).toFixed(2)}s |\n\n`;

const testcaseBlocks = xml.match(/<testcase[\s\S]*?<\/testcase>/g) ?? [];
if (testcaseBlocks.length > 0) {
  markdown += `<details>\n<summary>Test details</summary>\n\n`;
  markdown += `| Test | Result |\n|------|--------|\n`;
  for (const block of testcaseBlocks) {
    const nameMatch = block.match(/name="([^"]*)"/);
    const name = nameMatch ? nameMatch[1] : 'Unknown test';
    let result = '✅ Passed';
    if (block.includes('<failure')) result = '❌ Failed';
    else if (block.includes('<skipped')) result = '⏭️ Skipped';
    markdown += `| ${name} | ${result} |\n`;
  }
  markdown += `\n</details>\n`;
}

writeSummary(markdown);
