# Sprint Plan — nanoCSS Configurator

> **Project:** nanoCSS
> **Last Updated:** 2026-05-02
> **Sprint Cadence:** AI-assisted — 2–3 sprints per day (each sprint is a focused 1–3 hr session, not a two-week cycle)
> **Story Point Scale (recalibrated):** 1 pt ≈ 10–20 min · 2 pt ≈ 30–45 min · 3 pt ≈ 60–90 min · 5 pt ≈ 2–3 hr · 8 pt = must split
> **Velocity Reference:** Established at Sprint 5 close (see Retrospective below)

---

## Velocity Tracker

| Sprint | Planned | Completed | Velocity |
|---|---|---|---|
| Sprint 1 | 21 pts | 18 pts | 18 |
| Sprint 2 | 11 pts | 11 pts | 11 |
| Sprint 3 | 16 pts | 16 pts | 16 |
| Sprint 4 | 20 pts | 14 pts | 14 |
| Sprint 5 | 8 pts | 8 pts | 8 |
| **Rolling avg** | — | — | **~13 pts** |

---

## Sprint 5 Retrospective · Closed 2026-04-25

**Goal:** Introduce default SVG icons and a floating theme-switcher component.
**Result:** ACHIEVED — 8/8 pts delivered.

**What shipped?**
- UC-021: nanoCSS Icon Set (~20 inline SVG icons via `NanoIconHelper`)
- UC-022: Floating Theme Switcher component (`<prefix>-theme-switcher`, `<details>/<summary>` toggle, localStorage persistence)

**What also happened this sprint (non-code)?**
- Full documentation retrofit: PRD → v0.4, SYSTEM_DESIGN → v0.4, BACKLOG → Sprints 6–10, CHANGELOG → real history, ARCHITECTURE_DECISIONS → 6 real ADRs
- Obsidian preset concept added as UC-046, placed in Sprint 7

**Retrospective notes:**
- Velocity has ranged 8–18; settling to ~13 as a planning target
- Sprint 4 shortfall (14/20) was entirely UC-015 (chrome dogfooding) — correctly split into 3 Sprint 8 UCs
- Sprint 6 is deliberately tight (10 pts) to focus on spec compliance before Sprint 7's large scope

---

## ✅ Sprint 6 — Validation Enforcement & Spec Compliance · CLOSED 2026-05-03

> **Goal:** Close the gap between validators we *defined* and validators we *enforce*. Bring CI back to green. Harden the harmony swatch XSS surface.
> **Delivered:** 10/10 pts · All 5 stories shipped

| ID | Story | Points | Status |
|---|---|---|---|
| UC-023 | Wire validator gate into `ThemesController#preview` + `#download` | 3 | done |
| UC-024 | Strict 32-char prefix length validator | 1 | done |
| UC-025 | Externalise preset definitions to `config/presets.yml` | 2 | done |
| UC-026 | Repair 4 failing specs to match shipped reality | 2 | done |
| UC-027 | Harmony swatch XSS hardening (Stimulus, replace inline onclick) | 2 | done |

**Sprint goal check:** All criteria met — 85/85 specs green, 0 RuboCop offenses, validation gate in place, presets in YAML, inline onclick eliminated.

**Notable bug found and fixed during sprint:** `excluded_components: [""]` sentinel (from Rails hidden field) was failing the component validator on every preview request — silent bug pre-existing since Sprint 3, only surfaced when the validation gate was wired.

---

## Sprint 7 — NanoCSS Framework Polish, Responsiveness & Obsidian Capture · Planned

> **Goal:** Nail down the actual product — components, responsiveness, mobile. Capture the Obsidian glass-morphism aesthetic as a preset before Sprint 8 strips the source.
> **Dates (proposed):** 2026-05-09 → 2026-05-23
> **Capacity:** 26 pts

| ID | Story | Points | Status |
|---|---|---|---|
| UC-028 | Fix dropdown-inside-navbar (stays open) | 3 | todo |
| UC-029 | Mobile navbar with hamburger toggle | 5 | todo |
| UC-030 | Prefix Breadcrumb + Tooltip selectors (FR-011) | 2 | todo |
| UC-031 | Tier 1 dark mode `@media (prefers-color-scheme: dark)` | 2 | todo |
| UC-032 | Split monolithic `_components.scss` into modular partials | 5 | todo |
| UC-033 | Responsiveness sweep — all 20 components @ 4 breakpoints | 4 | todo |
| UC-046 | Obsidian Preset — capture glass-morphism, extend `ThemeConfiguration`, wire components | 5 | todo |

---

## Sprint 8 — Deep Dogfooding · Planned

> **Goal:** Make Quick Apply visibly re-skin the app. Replace custom chrome with nanoCSS components. Strip inline styles.
> **Dates (proposed):** 2026-05-23 → 2026-06-06
> **Capacity:** 18 pts

| ID | Story | Points | Status |
|---|---|---|---|
| UC-034 | Eliminate all 81 inline `style=` attributes in views | 5 | todo |
| UC-035 | Quick Apply visibly re-skins the app chrome | 5 | todo |
| UC-036 | Replace `.top-nav`/`.glass-panel`/`.configure-layout` with nanoCSS components | 5 | todo |
| UC-037 | Mount floating Theme Switcher in application layout | 3 | todo |

---

## Sprint 9 — Harmony Completion & Build Polish · Planned

> **Dates (proposed):** 2026-06-06 → 2026-06-20
> **Capacity:** 11 pts

| ID | Story | Points | Status |
|---|---|---|---|
| UC-038 | Add Monochromatic + Split-Complementary harmonies | 3 | todo |
| UC-039 | Component Catalogue sticky sidebar (IntersectionObserver) | 3 | todo |
| UC-040 | Real CSS minification via `Sass.compile_string(style: :compressed)` | 2 | todo |
| UC-041 | CI: validate generated CSS via W3C css-validator | 3 | todo |

---

## Sprint 10 — Deployment, Docs & Accessibility · Planned

> **Dates (proposed):** 2026-06-20 → 2026-07-04
> **Capacity:** 11 pts

| ID | Story | Points | Status |
|---|---|---|---|
| UC-042 | Capistrano runbook for IONOS AlmaLinux 9 VPS | 5 | todo |
| UC-043 | README rewrite | 2 | todo |
| UC-044 | PR template + CI lint for CHANGELOG entries | 1 | todo |
| UC-045 | WCAG 2.1 AA audit (axe-core/pa11y) | 3 | todo |
