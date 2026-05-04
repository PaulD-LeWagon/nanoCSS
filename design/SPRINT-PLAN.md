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
| Sprint 6 | 10 pts | 10 pts | 10 |
| Sprint 7 | 26 pts | 26 pts | 26 |
| **Rolling avg** | — | — | **~15 pts** |

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

## ✅ Sprint 7 — NanoCSS Framework Polish, Responsiveness & Obsidian Capture · CLOSED 2026-05-04

> **Goal:** Nail down the actual product — components, responsiveness, mobile. Capture the Obsidian glass-morphism aesthetic as a preset before Sprint 8 strips the source.
> **Delivered:** 26/26 pts · All 7 stories shipped

| ID | Story | Points | Status |
|---|---|---|---|
| UC-028 | Fix dropdown-inside-navbar (stays open) | 3 | done |
| UC-029 | Mobile navbar with hamburger toggle | 5 | done |
| UC-030 | Prefix Breadcrumb + Tooltip selectors (FR-011) | 2 | done |
| UC-031 | Tier 1 dark mode `@media (prefers-color-scheme: dark)` | 2 | done |
| UC-032 | Split monolithic `_components.scss` into modular partials | 5 | done |
| UC-033 | Responsiveness sweep — all 20 components @ 4 breakpoints | 4 | done |
| UC-046 | Obsidian Preset — capture glass-morphism, extend `ThemeConfiguration`, wire components | 5 | done |

**Sprint goal check:** All 7 stories committed and 125 specs green. Sprint goal achieved.

**Sprint 7 Retrospective · 2026-05-04**

**What shipped?**
- UC-028/029: Navbar fully functional — dropdown-in-navbar bug fixed via Stimulus `dropdown_controller`; mobile hamburger menu wired with Esc-close and `aria-expanded` tracking.
- UC-030: Breadcrumb and Tooltip selectors prefixed (`.{prefix}-breadcrumb`, `.{prefix}-tooltip`) with backward-compat aliases.
- UC-031: Three-tier dark mode — Tier 1 OS media query, Tier 2 explicit `[data-theme]` overrides.
- UC-032: Monolithic `_components.scss` split into 18 individual partials under `components/`; `ScssCompilerService` exclusion logic replaced with a clean COMPONENT_ALIASES include-list.
- UC-033: Responsiveness sweep spec suite (4 breakpoints × 2 assertions); all viewports already clean from UC-029.
- UC-046: Obsidian glass-morphism preset — 3 new glass-surface tokens, 4th preset card on landing page, hero uses CSS-var gradient, card/nav gain `backdrop-filter`.

**What broke (visual QA findings, 2026-05-04)?**
Four regressions surfaced during manual QA. All raised as UC-047–UC-050, promoted to top of Sprint 8:

1. **Dark mode theme-switcher broken** (UC-047): UC-031's OS media query means removing `data-theme` no longer restores light mode. `theme_controller.js` must set `data-theme="light"` explicitly.
2. **Catalogue dark-mode contamination** (UC-048): OS media query inverts neutral tokens globally — catalogue component renders show dark-on-dark text on machines with OS dark mode.
3. **Hero `color: #fff` cascades** (UC-049): UC-046's hero gradient change added `color: #fff` which cascades into nested child components.
4. **Live preview — body font + breadcrumb** (UC-050): body font changes don't update the preview pane; breadcrumb shows broken styling in the preview context.

**Quick Apply not reskinning chrome** — confirmed by QA; tracked as UC-035 (Sprint 8 planned story, unchanged).

**Retrospective notes:**
- Sprint 7 was the largest sprint to date (26 pts, 7 stories) and every story passed automated DoD gates.
- The four regressions are purely visual and all traceable to three specific decisions: the UC-031 media query scoping, the UC-046 hero `color: #fff`, and the preview scoping of breadcrumbs. No data loss, no security issues.
- Mitigation for Sprint 8: run visual QA on the preview pane and catalogue page immediately after each story commit, before moving to the next story.

---

## Sprint 8 — Sprint 7 Regressions + Deep Dogfooding · Planned

> **Goal:** Fix four visual regressions first (UC-047–UC-050), then execute the dogfooding plan. Quick Apply must visibly re-skin the app. Replace custom chrome with nanoCSS components. Strip inline styles.
> **Dates (proposed):** 2026-05-23 → 2026-06-06
> **Capacity:** 26 pts

| ID | Story | Points | Status |
|---|---|---|---|
| UC-047 | Fix dark mode theme-switcher regression | 1 | todo |
| UC-048 | Fix dark-mode contamination of Component Catalogue | 2 | todo |
| UC-049 | Fix hero `color: #fff` cascade | 1 | todo |
| UC-050 | Fix live preview — body font + breadcrumb rendering | 2 | todo |
| UC-034 | Eliminate all 81 inline `style=` attributes in views | 5 | todo |
| UC-035 | Quick Apply visibly re-skins the app chrome | 5 | todo |
| UC-036 | Replace `.top-nav`/`.glass-panel`/`.configure-layout` with nanoCSS components | 5 | todo |
| UC-037 | Mount floating Theme Switcher in application layout | 3 | todo |

> **Note:** UC-047–UC-050 are regression fixes that should be resolved before beginning UC-034 work. The remaining 6 pts buffer can be used if any regression fix proves unexpectedly complex.

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
