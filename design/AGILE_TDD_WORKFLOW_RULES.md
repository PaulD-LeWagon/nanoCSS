# Agile & TDD Workflow Rules

> **Project:** [Project Name]
> **Version:** 1.0
> **Purpose:** The master reference for how this project is built.
> Every phase, every rule, every document — in one place.

---

## Document Map

| Document                           | Phase | Purpose                                               |
| ---------------------------------- | ----- | ----------------------------------------------------- |
| `ARCHITECTURE_DECISIONS.md`        | 0+    | The why behind every significant technical decision   |
| `PROJECT_REQUIREMENTS_DOCUMENT.md` | 1.0   | The non-technical problem definition and requirements |
| `BACKLOG.md`                       | 2.1   | Prioritised Use Cases with Acceptance Criteria        |
| `UI_COMPONENTS.md`                 | 2.2   | UX, user journeys, and UI component specifications    |
| `SYSTEM_DESIGN.md`                 | 3.1   | Technical architecture and module design              |
| `ENVIRONMENT.md`                   | 3.2   | How to set up and run the project locally             |
| `SECURITY.md`                      | 3.3   | Threat model, auth design, data handling, compliance  |
| `TDD_CYCLE.md`                     | 4.1   | The test process follow                               |
| `CHANGELOG.md`                     | 4.2+  | Human-readable history of every release               |
| `ERROR_HANDLING.md`                | 4.3   | Error taxonomy, response shapes, logging rules        |
| `RELEASE_CHECKLIST.md`             | 5.0   | The gate between green tests and production           |

---

## Phase 1: The (Fuzzy) Idea — Product Requirements Document

**Goal:** Understand the real-world problem before writing a line of code.

**Output:** `PRD.md` — agreed with all stakeholders.

**Rules:**
- Write in plain, non-technical English. Focus on the *problem*, not the solution.
- Converse with the user at all stages. Do not proceed to the next phase until the PRD is signed off.
- Explicitly document what is **Out of Scope** — this is your primary defence against scope creep.
- Document assumptions early. Unexamined assumptions are future bugs.

**PRD Sections (in order):**
1. Executive Summary
2. Assumptions & Dependencies
3. Out of Scope
4. Functional Requirements
5. User Flow
6. Non-Functional Requirements
7. Technical Constraints & Environment
8. Security & Compliance
9. Success Metrics (Definition of Done)

---

## Phase 2: Agile Planning

### Phase 2.1 Backlog First

**Goal:** Translate the PRD into a prioritised, actionable backlog before any design or code.

**Output:** `BACKLOG.md` — Sprint 1 Use Cases meeting the Definition of Ready.

**Rules:**
- **No coding until the backlog is written.**
- Every Use Case must follow the format: *"As a [user], I want to [action] so that [value]."*
- Every Use Case must have specific, independently testable Acceptance Criteria and a test-type annotation - e.g. \[unit|integration|E2E\] (Or framework specific equivalents).
- Every Use Case must have Story Points assigned.
- Maintain an **Icebox** section for unscheduled ideas — never delete a validated idea.
- Define and agree the **Sprint cadence** (e.g. 1-week Sprints) before Sprint 1 begins.
- Define your **Sprint capacity** (total story points the team can deliver per Sprint).

**Backlog Sync Rule (ongoing from Phase 3):**
After every TDD cycle, ask: *"Does the backlog still accurately describe what the code does?"*
If no: update the relevant Acceptance Criteria with a dated note and log the change in the Backlog Sync Log. If the change is architectural, also write an ADR in ARCHITECTURE_DECISIONS.md.

---

## Phase 2.2: UX & Interface Design

**Goal:** Define the user experience and every UI component *before* system design — so the interface shapes the architecture, not the other way around.

**Output:** `UI_COMPONENTS.md`

**Rules:**
- Complete this phase after the backlog is written (so you know what screens are needed) and before system design (so the UI informs technical decisions).
- Every Use Case that involves a UI must have its components named in `UI_COMPONENTS.md` before it can enter a Sprint.
- Every component must have all states designed: Default, Loading, Error, Empty, Disabled.
- Accessibility is designed in — not added later. WCAG 2.1 AA is the minimum standard.

---

## Phase 3: System Design

**Goal:** Translate Use Cases into a concrete technical design — just enough for the current Sprint.

**Output:** `SYSTEM_DESIGN.md` (living), `ARCHITECTURE_DECISIONS.md` (living), `ENVIRONMENT.md`, `SECURITY.md`

**Rules:**
- **Do not over-design.** Only design what you need for the current Sprint (YAGNI).
- `SYSTEM_DESIGN.md` is a **single living document**, divided by Sprint. Never create one file per Sprint.
- Define cross-cutting concerns **first** (auth, error handling, logging, testing strategy, git branching) — these inform all Sprint-specific design.
- For every significant decision you considered alternatives for, write an **ADR**. The ADR captures *why*, not just *what*.
- ADRs are **append-only** — never rewrite or delete. Supersede with a new ADR.
- `SECURITY.md` must be drafted before Sprint 1 begins.
- `ENVIRONMENT.md` must be complete before any developer joins the project.

---

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

---

## Phase 5: Release Checklist

**Goal:** Ensure "tests are green" and "this is production-ready" are the same thing.

**Output:** Completed `RELEASE_CHECKLIST.md` for every Sprint release.

**The checklist covers:**
- Code quality (tests, lint, type check)
- Testing (AC verification, E2E, browser, mobile)
- Security (audit, secrets, headers, rate limiting)
- Accessibility (automated scan, keyboard, contrast)
- Performance (load time, API latency, N+1 queries)
- Observability (logging, alerting)
- Documentation (all docs updated)
- Deployment (staging verified, rollback plan, smoke tests)
- Post-release monitoring

**Rule:** No release ships without a completed checklist. "Done" means the checklist is signed off.

---

## Design Principles (Apply in Phase 3)

### Always Apply
| Principle | Rule |
|---|---|
| **SOLID** | Single Responsibility, Open-Closed, Liskov Substitution, Interface Segregation, Dependency Inversion. Minimises fragile, rigid, complex code. |
| **KISS** | Keep It Simple. Over-engineering is a primary project killer. |
| **Composition over Inheritance** | Favour flexible interfaces and wrappers over deep class hierarchies. |
| **DRY** | Don't Repeat Yourself — for logic. Avoid dogmatic DRY that creates tight coupling. |
| **Separation of Concerns** | UI, business logic, and data persistence are distinct layers. |
| **YAGNI** | Only build for today's requirements. Not the ones you imagine for tomorrow. |
| **Design for Observability** | Software must be built to be monitored, logged, and traced from the start. |

### Never Apply
| Antipattern | Why |
|---|---|
| **Deep Inheritance Hierarchies** | God classes with many child levels are a maintenance nightmare. |
| **The Golden Hammer** | No single pattern (e.g. pure MVC) fits every problem. |
| **Premature Optimisation** | Don't optimise until you have evidence of a real performance problem. |
| **Rigid Upfront Design** | Don't map every class and schema before writing a line of code. |
| **Hungarian Notation** | Adding type prefixes to names (e.g. `strName`, `iCount`). IDEs and type systems make this redundant. |
| **Global State / Singletons as default** | They make unit testing and parallel processing extremely difficult. |

---

## Mocking Rules (Phase 4)

> _Tests that depend on real external state are fragile. Mock at the boundary._

| What to Mock              | Why                                                    | How                                                                                                                        |
| ------------------------- | ------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------- |
| External APIs (3rd party) | Rate limits, cost, network unreliability               | Mock response objects / intercept library                                                                                  |
| The clock (`Date.now()`)  | Tests that depend on real time are flaky               | Inject time as a dependency; so, use `jest.useFakeTimers()` for timers, etc. or the actual test suite's equivalent method. |
| The filesystem (`fs`)     | Tests that depend on real paths fail on other machines | Inject `fs` as a dependency; use `memfs` for complex cases or test framework's equivalent.                                 |
| The database              | Slow tests, data pollution                             | Use a dedicated test database instance; never the dev DB                                                                   |

**Rule:** Use live API/service calls only in final E2E tests — not unit or integration tests.

---

## Git Commit Convention

Format: `type(scope): short description [UC-NNN]`

| Type | Use When |
|---|---|
| `feat` | New feature or Use Case |
| `fix` | Bug fix |
| `test` | Adding or updating tests |
| `refactor` | Code improvement — no behaviour change |
| `docs` | Documentation only |
| `chore` | Build, config, dependency update |
| `security` | Security fix or hardening |

**Rule:** Commit after every successful Red-Green-Refactor cycle. Small, frequent commits.

---

## Revision History

| Version | Date | Author | Change |
|---|---|---|---|
| 1.0 | [YYYY-MM-DD] | [Name] | Initial version |
