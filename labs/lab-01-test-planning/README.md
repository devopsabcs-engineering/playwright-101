---
layout: default
title: "Lab 01: From User Stories to Test Cases"
nav_order: 3
description: "Map user stories and acceptance criteria to testable scenarios"
permalink: /labs/lab-01-test-planning/
---

| | |
|---|---|
| **Duration** | 10 minutes |
| **Level** | Beginner |
| **Type** | Conceptual + Demo |

## Learning Objectives

After completing this lab, you will be able to:

* Map user stories through acceptance criteria to concrete test cases
* Identify testable scenarios from requirements
* Organize test cases by priority and complexity

## Prerequisites

* [Lab 00: Prerequisites](../lab-00-prerequisites/) completed

## Exercises

### Exercise 1: Read the User Story

Consider this ServiceOntario user story:

> **As a** citizen,
> **I want to** search ontario.ca for government services
> **so that** I can find information quickly.

This story describes a real search feature on ontario.ca. The workshop test suite
targets this exact functionality, giving you a concrete reference point for every
test you write.

### Exercise 2: Map Acceptance Criteria

Acceptance criteria define the boundaries of "done" for a user story. Extract
criteria from the story above by asking: "What must be true for this feature to
work correctly?"

| # | Acceptance Criterion |
|---|---|
| AC-1 | Search returns relevant results for a given query |
| AC-2 | Results can be filtered by topic |
| AC-3 | Results can be sorted by date |
| AC-4 | Pagination works for large result sets |
| AC-5 | Empty or nonsense search shows an appropriate message |

Each criterion is independently verifiable. That property makes them ideal
inputs for automated tests.

### Exercise 3: Create Test Scenarios

Map each acceptance criterion to a test scenario. The table below connects
criteria to the actual tests in `ontario-search.spec.ts`:

| Acceptance Criterion | Test Scenario | Test Name in Spec |
|---|---|---|
| AC-1: Search returns results | Verify search results appear for "driver licence" | `search for driver licence returns results` |
| AC-2: Filter by topic | Apply a topic filter and confirm results update | `filter by topic narrows results` |
| AC-3: Sort by date | Select "Updated date" sort and verify results reload | `sort results by updated date` |
| AC-4: Pagination | Navigate to page 2 and confirm active page changes | `pagination navigates to next page` |
| AC-5: Empty search | Search a nonsense query and verify "0 results" message | `search with no results shows empty state` |

Two additional tests round out the suite:

* `navigate to Ontario.ca search page` validates basic page load and title
* `search input field is visible and functional` confirms the search box accepts
  new queries

### Exercise 4: Prioritize Test Scenarios

Not all tests carry equal weight. Rank scenarios by risk and user impact:

1. **Search returns results** (highest risk: core functionality)
2. **Filter by topic** (high: primary refinement path)
3. **Sort by date** (medium: secondary refinement)
4. **Pagination** (medium: needed for large result sets)
5. **Empty search** (lower: edge case, but affects user trust)
6. **Basic navigation** (lower: foundation, rarely breaks alone)
7. **Search input field** (lower: UI presence check)

This ranking guides where to invest effort first when building or maintaining a
test suite.

### Exercise 5: Discussion

Consider how manual test cases become automation targets:

* The acceptance criteria remain the same whether you test manually or automate.
* Automation adds repeatability: the same assertions run on every code change.
* Manual testing still matters for exploratory scenarios that are hard to script.
* The mapping table from Exercise 3 becomes your automation backlog.

> [!NOTE]
> In enterprise environments, tools like
> [Azure Test Plans](https://learn.microsoft.com/en-us/azure/devops/test/overview)
> provide traceability from requirements through test cases to execution results.
> The mapping approach you practiced here scales directly into that workflow.

## Verification Checkpoint

You have a list of 5 to 7 test scenarios mapped from the user story, each linked
to an acceptance criterion and a named test in the spec file.

## Summary

Test planning is the foundation of effective automation. You translated a user story
into acceptance criteria, mapped those criteria to concrete test scenarios, and
prioritized them by risk. The next lab puts these scenarios into action with
Playwright.

## Next Steps

Proceed to [Lab 02: Your First Playwright Test](../lab-02-playwright-basics/).
