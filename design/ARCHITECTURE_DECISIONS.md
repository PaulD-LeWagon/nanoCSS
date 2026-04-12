# Architecture Decision Records (ADR)

> **Project:** nanoCSS
> **Purpose:** To record not just WHAT was decided, but WHY — so future developers
> do not accidentally undo decisions made for reasons they cannot see in the code.
> **Rule:** ADRs are append-only. Never delete or rewrite an existing record.
> If a decision is reversed, add a new ADR that supersedes the old one.

---

## How to Write an ADR

Create a new entry for any decision that:
- Affects more than one module or layer of the system
- Would be non-trivial to reverse
- Was not obvious — i.e. you considered at least one alternative
- Changed an existing Acceptance Criterion or Use Case

Use the next sequential ID. Set status to **Proposed** → **Accepted** → **Superseded**.

---

## ADR Index

| ID | Title | Status | Sprint | Date |
|---|---|---|---|---|
| ADR-001 | [Decision title] | ✅ Accepted | Sprint 1 | [YYYY-MM-DD] |
| ADR-002 | [Decision title] | ✅ Accepted | Sprint 1 | [YYYY-MM-DD] |
| ADR-003 | [Decision title] | 🔴 Superseded by ADR-007 | Sprint 2 | [YYYY-MM-DD] |

---

## ADR-001 · [Decision Title]

**Date:** [YYYY-MM-DD]
**Sprint:** Sprint [N]
**Status:** ✅ Accepted | 🟡 Proposed | 🔴 Superseded by ADR-[N]
**Author:** [Name]

### Context
> _What situation or problem forced this decision? What constraints were in play?
> What would have happened if no decision had been made?_

[Describe the context here.]

### Decision
> _What did you decide to do? State it clearly and without ambiguity._

[State the decision here.]

### Alternatives Considered
| Option | Reason Rejected |
|---|---|
| [Option A] | [Why you didn't choose it] |
| [Option B] | [Why you didn't choose it] |

### Consequences
> _What becomes easier or harder as a result of this decision?
> What technical debt, if any, does this introduce?_

**Positive:**
- [e.g. Simpler testing — no external service required in unit tests]

**Negative / Trade-offs:**
- [e.g. Will need to revisit if scale exceeds X users]

### Related
- Backlog: [e.g. UC-001 AC2 updated — see Backlog Sync Log entry YYYY-MM-DD]
- PRD: [e.g. Section 8 — Security & Compliance]

---

## ADR-002 · [Decision Title]

**Date:** [YYYY-MM-DD]
**Sprint:** Sprint [N]
**Status:** ✅ Accepted
**Author:** [Name]

### Context
[Describe the context here.]

### Decision
[State the decision here.]

### Alternatives Considered
| Option | Reason Rejected |
|---|---|
| [Option A] | [Why you didn't choose it] |

### Consequences
**Positive:**
- [Consequence]

**Negative / Trade-offs:**
- [Trade-off]

### Related
- [Links to backlog, PRD sections, or other ADRs]

---

## ADR-003 · [Decision Title] 🔴 Superseded

**Date:** [YYYY-MM-DD]
**Sprint:** Sprint [N]
**Status:** 🔴 Superseded by ADR-[N] on [YYYY-MM-DD]
**Author:** [Name]

### Context
[Original context.]

### Decision
[Original decision — do not edit this.]

### Why This Was Superseded
[Brief explanation of what changed to make this decision no longer valid.]

### Consequences of Supersession
- [What changed as a result]

---

_Add new ADRs below this line, incrementing the ID._
