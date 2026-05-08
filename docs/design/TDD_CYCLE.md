---
vc-id: 3d3f7714-fb02-4267-b244-25f65051edb6
---
# TDD_CYCLE

> **Project:** nanoCSS
> **Date:** 2026-05-07
> **Status:** 🟢 Active

## Phase 4: The TDD Cycle

**Goal:** Build working, tested, observable software one Use Case at a time.

**The cycle (repeat for every Use Case):**

### Step 1 — RED 🔴
Generate a test file based on the Acceptance Criteria.
Run it. It **must fail** before you write any implementation code.
A test that passes before implementation is a broken test.

### Step 2 — GREEN 🟢
Write the **minimum** code required to make the test pass.
No gold-plating. No extras. Just green.

### Step 3 — REFACTOR 🔵
Improve the code while the tests stay green.
Apply SOLID, KISS, DRY, Separation of Concerns.
Avoid the antipatterns listed below.

### Step 4 — OBSERVABILITY 👁
Before marking the Use Case done, ask:
*"What does healthy look like for this feature in production?"*
Ensure appropriate logging calls, metrics, or health indicators are in place.
Observability is not an afterthought — it is part of Done.

### Step 5 — COMMIT 💾
`git commit` with a meaningful Conventional Commit message.
Format: `type(scope): description [UC-NNN]`
Example: `feat(auth): add account lockout after 5 failed attempts [UC-002]`

### Step 6 — SYNC BACKLOG 🔄
Ask: *"Does the backlog still accurately describe what the code does?"*
If a behaviour changed during implementation: update the Acceptance Criteria with a dated note, log it in the Backlog Sync Log, and write an ADR if it was an architectural decision.