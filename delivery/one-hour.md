---
layout: default
title: "Facilitator Guide — 1-Hour Delivery"
nav_exclude: true
description: "Instructor guide for delivering the Playwright 101 workshop in a 1-hour session with timing, setup checklist, and talking points."
---

## Audience

This guide is intended for the workshop facilitator or instructor delivering the
Playwright 101 workshop in a 1-hour format.

## Pre-Workshop Checklist

- Verify ontario.ca/search is accessible (load
  <https://www.ontario.ca/search?query=driver+licence> in a browser)
- Confirm the GitHub Pages site is live at
  <https://devopsabcs-engineering.github.io/playwright-101/>
- Test all Playwright tests pass locally: `cd playwright-tests && npx playwright test`
- Ensure attendees received the prerequisites link (Lab 00 URL)
- Verify Wi-Fi and projector or screen sharing work

## Agenda

| Time | Activity | Notes |
|------|----------|-------|
| 0:00–0:02 | Welcome and overview | Share GitHub Pages URL |
| 0:02–0:12 | Lab 01: Test Planning | Instructor-led walkthrough |
| 0:12–0:32 | Lab 02: Playwright Basics | Hands-on with instructor support |
| 0:32–0:47 | Lab 03: Copilot Testing | Hands-on; have fallback for no Copilot |
| 0:47–0:57 | Lab 04: CI Pipeline | Demo + guided configuration |
| 0:57–1:00 | Wrap-up and Q&A | Share resources |

## Key Talking Points

### Lab 01: Test Planning

Automation starts with good requirements. User stories bridge the gap between
business needs and test cases. Encourage participants to think about acceptance
criteria before writing any code.

### Lab 02: Playwright Basics

Highlight Playwright's auto-waiting behavior, which eliminates the need for
explicit waits. Walk through multiple locator strategies (role, text, CSS, test ID)
and demonstrate the Trace Viewer for debugging failed tests.

### Lab 03: Copilot-Assisted Testing

Introduce the two-prompt technique: provide context first, then make the request.
Remind participants to always validate Copilot output against the live site, because
generated selectors may not match current page structure.

### Lab 04: CI Pipeline

CI/CD ensures tests run on every code change, catching regressions early. Artifacts
provide historical test reports that the team can review without re-running tests.

## Common Issues and Solutions

| Issue | Solution |
|-------|----------|
| Node.js version mismatch | Verify `node --version` shows v20+; use nvm to switch |
| Tests timeout on first run | ontario.ca React SPA needs warm-up; increase timeout or retry |
| Language splash page appears | Cookie handling in beforeEach should prevent this; verify cookie domain is `.ontario.ca` |
| Selector not found | ontario.ca may update HTML; check selectors against live page |
| npm install fails | Clear node_modules and package-lock.json, retry |
| Copilot not available | Provide manual code snippets as fallback; lab exercises include expected output |

## Fallback Plan

If ontario.ca is down during the workshop:

- Use cached screenshots to demonstrate concepts
- Discuss the test approach theoretically
- Show the test code and explain expected behavior
- Reschedule hands-on execution for a follow-up session

## Resources and Further Learning

- [Playwright Documentation](https://playwright.dev)
- [Microsoft Learn: End-to-end testing with Playwright](https://learn.microsoft.com/en-us/training/modules/build-with-playwright/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Azure Test Plans](https://learn.microsoft.com/en-us/azure/devops/test/overview)
