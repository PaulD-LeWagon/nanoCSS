---
vc-id: 895acb54-d6d8-45b5-a91e-a735affb2eb8
---
# Product Backlog

> **Project:** nanoCSS
> **Last Updated:** 2026-05-05 (Sprint 8 close — all 8 stories shipped, 145 specs green)
> **Current Sprint:** Sprint 8 closed → Sprint 9 opening
> **Sprint Cadence:** AI-assisted — 2–3 sprints per day

---

## Definition of Ready

- [x] Written in the agreed Use Case format ("As a... I want to... so that...")
- [x] Acceptance Criteria are fully written and independently testable
- [x] UI component(s) identified and documented in `UI_COMPONENTS.md`
- [x] External dependencies or blockers are named
- [x] Story Points have been assigned by the team
- [ ] No unresolved questions or ambiguities remain

---

## Definition of Done

- [ ] All Acceptance Criteria pass
- [ ] Unit and integration tests are green (RSpec, Capybara, Selenium)
- [ ] No new linting errors introduced (RuboCop)
- [ ] `BACKLOG.md` is synced
- [ ] Relevant docs updated (`CHANGELOG.md`, `UI_COMPONENTS.md` if applicable)
- [ ] Code reviewed and merged to main branch

---

## Story Point Reference

| Points | Meaning |
|---|---|
| 1 | Trivial — under an hour |
| 2 | Small — a few hours |
| 3 | Medium — roughly a day |
| 5 | Large — 2–3 days |
| 8 | Very large — consider splitting |
| 13+ | Too big — must be split before entering a Sprint |

---

## Priority Key

| Label           | Meaning                                       |
| --------------- | --------------------------------------------- |
| 🟥 Must Have    | Core — product does not function without this |
| 🟧 Should Have  | Important — significant impact if missing     |
| 🟦 Nice to Have | Desirable — low impact if deferred            |
| 🧊 Icebox       | Future consideration — not in current roadmap |

## Status Key

| Status         | Meaning                                     |
| -------------- | ------------------------------------------- |
| ⚪ To Do        | Ready and prioritised, not yet started      |
| 🔵 In Progress | Actively being worked on this Sprint        |
| 🟢 Done        | All Definition of Done criteria met         |
| 🟡 Partial     | Shipped but with known gaps tracked elsewhere |
| 🔴 Blocked     | Cannot proceed — blocker named below        |
| 🧊 Icebox      | Deferred to a future Sprint or indefinitely |

---

## Sprint 1 — The Core Engine & Customisation · _Closed_

> **Sprint Goal:** Deliver a stateless MVP where a user can configure a theme, preview it live via Hotwire, and download the compiled SCSS/CSS zip.
> **Sprint Dates:** 2026-04-11 → 2026-04-25
> **Sprint Capacity:** 25 story points · **Delivered:** 21 pts (3 carried, 1 partial)

---

### UC-001 · Preset Theme & Live Preview · 🟥 Must Have · 5 pts · 🟢 Done

**As an** indie developer,
**I want to** select a preset theme and see it instantly,
**so that** I can quickly evaluate the framework without manual configuration.

**Acceptance Criteria:**
- AC1: Landing page displays three preset cards (Corporate, Playful, Minimalist). [system] ✅
- AC2: Clicking a preset instantly applies it to the preview pane without a full page reload. [system] ✅ (mechanism updated by UC-016 — see ADR-003)
- AC3: The preview DOM updates within 200ms. [integration] ✅

**Dependencies:** None
**UI Components:** `<ThemeCard>`, `<PreviewPane>`
**Status:** 🟢 Done — Sprint 1

---

### UC-002 · Custom Theme Configuration Form · 🟥 Must Have · 8 pts · 🟢 Done

**As an** indie developer,
**I want to** configure specific brand colours, fonts, and spacing,
**so that** the framework matches my exact design requirements.

**Acceptance Criteria:**
- AC1: Form exposes Basic Mode (anchor variables) and Advanced Mode (individual overrides). [unit] ✅
- AC2: Switching modes retains previously entered values. [integration] ✅
- AC3: Invalid hex codes (`#123` or `#zzz`) are rejected server-side. [unit] 🟡 — validators exist but are not invoked by the controller (see UC-023)
- AC4: Valid inputs trigger a Hotwire Turbo Stream update to the preview pane. [system] ✅
- AC5: Advanced Mode correctly decouples Margin Base from Spacing (Padding) Base in the generated SCSS variables. ✅
- AC6: The UI form successfully captures and passes the 5-part Drop Shadow and Text Shadow matrices to the `ScssCompilerService`. ✅
- AC7: The Google Fonts selector successfully applies the newly added Code Font selection to the `--nanocss-font-code` variable. ✅ (added in Sprint 3 alongside UC-014)

**Dependencies:** UC-001
**UI Components:** `<ConfigSidebar>`, `<ModeToggle>`, `<ColourPicker>`
**Status:** 🟡 Partial (AC3 server-side rejection deferred to UC-023)

---

### UC-003 · Download / Export Engine · 🟥 Must Have · 5 pts · 🟡 Partial

**As an** indie developer,
**I want to** download my tailored framework as a .zip file,
**so that** I can drop it directly into my project.

**Acceptance Criteria:**
- AC1: Clicking "Download" streams a .zip file to the client within 2 seconds. [integration] ✅
- AC2: The archive contains `nanocss.css`, `nanocss.min.css`, and a `scss/` directory. [unit] 🟡 — `nanocss.min.css` is currently produced by `gsub(/\s+/, ' ')` which is incorrect; real minification deferred to UC-039
- AC3: All SCSS variables and filenames respect the user's custom prefix. [unit] ✅

**Dependencies:** UC-002
**UI Components:** `<DownloadButton>`
**Status:** 🟡 Partial (real minification deferred to UC-039, modular SCSS partials deferred to UC-032)

---

### UC-004 · Shareable Theme URLs · 🟥 Must Have · 3 pts · 🟢 Done

**As an** indie developer,
**I want to** generate a URL encoding my configuration,
**so that** I can bookmark or share my theme without needing an account.

**Acceptance Criteria:**
- AC1: Clicking "Copy Share Link" copies a URL with a base64 encoded `?theme=` parameter. [system] ✅
- AC2: Visiting a URL with a valid `?theme=` parameter pre-populates the config form and preview. [system] ✅
- AC3: Edge case — malformed `?theme=` data gracefully falls back to the default theme. [unit] ✅

**Dependencies:** UC-002
**Status:** 🟢 Done — Sprint 4 (originally Sprint 1; the encode/decode round-trip was repaired in UC-018)

---

## Sprint 2 — Refinement & Component Catalogue · _Closed_

> **Sprint Goal:** Stand up the full 17-component catalogue and add HSL harmony suggestions to the colour picker.
> **Sprint Dates:** 2026-04-25 → 2026-05-09
> **Sprint Capacity:** 13 story points · **Delivered:** 11 pts

---

### UC-005 · Component Catalogue Reference · 🟥 Must Have · 5 pts · 🟡 Partial

**As an** indie developer,
**I want to** browse all available components with their HTML/JS snippets,
**so that** I can easily copy-paste them into my project.

**Acceptance Criteria:**
- AC1: Dedicated page displays all 20 components with live renders. [system] 🟡 — the page exists; visual quality issues remain (see UC-019, UC-033)
- AC2: Raw HTML snippets use the currently active namespace prefix. [unit] ✅
- AC3: Clicking the copy icon copies the snippet to the clipboard and shows a toast. [system] ✅

**Status:** 🟡 Partial — visual polish deferred to UC-033 (Sprint 7)

---

### UC-006 · Colour Harmony Generator · 🟧 Should Have · 3 pts · 🟡 Partial

**As an** indie developer,
**I want to** receive automatic secondary/tertiary colour suggestions,
**so that** I can quickly build a cohesive palette based on my primary brand colour.

**Acceptance Criteria:**
- AC1: Entering a Primary hex suggests Complementary, Analogous, Triadic, etc., palettes. [unit] 🟡 — 3 of the 5 PRD-specified harmonies shipped (Monochromatic, Split-Complementary deferred to UC-037)
- AC2: Clicking a suggestion populates the Secondary and Tertiary inputs. [system] ✅

**Status:** 🟡 Partial — remaining harmonies in UC-037 (Sprint 9)

---

### UC-007 · Card Component Variants (Sprint-2 retrofit) · 🟧 Should Have · 3 pts · 🟢 Done

**As an** indie developer,
**I want** four ready-to-use Card variants (Basic, Image-First, Profile, Stat),
**so that** I have well-styled containers for the most common UI surfaces without authoring layout from scratch.

**Acceptance Criteria:**
- AC1: All four Card variants render correctly under each preset theme. ✅
- AC2: Variants are documented in the Component Catalogue. ✅
- AC3: Variants degrade to a single column at the mobile breakpoint. 🟡 — covered by UC-033 sweep

**Status:** 🟢 Done — Sprint 2 (retrofitted into the backlog at Sprint 5 close — was tracked only in PRD v0.4 §10)

---

## Sprint 3 — Typography, Layering, & Granular Control · _Closed_

> **Sprint Goal:** Fully integrate the Google Fonts API for dynamic typography, introduce granular per-component toggling, and implement auto-tinting for a polished v1.0 release.
> **Sprint Dates:** 2026-05-09 → 2026-05-23
> **Sprint Capacity:** 16 story points · **Delivered:** 16 pts

---

### UC-014 · Google Fonts API Integration (FR-008) · 🟧 Should Have · 5 pts · 🟢 Done

**As an** indie developer,
**I want to** search and select from the Google Fonts catalogue directly within the config sidebar,
**so that** I can easily assign distinct typefaces to Headers, Subtitles, Body, and Code.

**Acceptance Criteria:**
- AC1: `GoogleFontsService` fetches the font catalogue and caches it for 24 h. ✅
- AC2: Stimulus controllers power search and select dropdowns for Heading, Subtitle, Body, and Code slots. ✅
- AC3: **Security:** `ThemeConfiguration` strictly validates the selected font string against the cached whitelist *before* interpolating into `@import url(...)`. ✅
- AC4: The SCSS compiler injects the valid Google Fonts `@import` rule at the top of the generated CSS and sets the corresponding `--{prefix}-font-*` CSS custom properties. ✅

**Status:** 🟢 Done — Sprint 3

---

### UC-010 · Per-Component Toggle Selection · 🟧 Should Have · 5 pts · 🟡 Partial

**As an** indie developer,
**I want to** explicitly select or exclude individual components,
**so that** I can minimise my CSS footprint to exactly what I need.

**Acceptance Criteria:**
- AC1: Configuration UI displays a dynamic list of checkboxes for components. ✅
- AC2: Deselected components are omitted from both the generated `nanocss.css` string and the compiled `scss/` ZIP folder. 🟡 — implementation uses brittle regex-strip on the monolithic `_components.scss`; modular replacement deferred to UC-032
- AC3: The preview gracefully handles missing components. ✅

**Status:** 🟡 Partial — exclusion mechanism is fragile (UC-032 in Sprint 7)

---

### UC-011 · Automated Semantic Colour Tinting (FR-007) · 🟧 Should Have · 3 pts · 🟢 Done

**As an** indie developer,
**I want** my semantic utility classes (success, info, warning, danger) to automatically harmonise with my primary brand colour,
**so that** the framework feels visually cohesive without manual colour-picking.

**Acceptance Criteria:**
- AC1: SCSS engine applies `color.mix()` to blend the user's Primary hex into the four semantic defaults. ✅
- AC2: Resulting hex colours compile cleanly. ✅
- AC3: Resulting tinted colours maintain passing WCAG 2.1 AA text contrast. 🟡 — formal audit in UC-043 (Sprint 10)

**Status:** 🟢 Done — Sprint 3 (formal contrast audit deferred to UC-043)

---

### UC-012 · CSS Layer (`@layer`) Support · 🟦 Nice to Have · 3 pts · 🟢 Done

**As an** indie developer integrating nanoCSS into a legacy app,
**I want** the framework's output to be wrapped in a specific CSS `@layer`,
**so that** I don't suffer specificity wars against my existing legacy stylesheets.

**Acceptance Criteria:**
- AC1: Configuration form provides advanced toggle: "Wrap in CSS `@layer`". ✅
- AC2: Final output groups rules into scoped layers (`@layer prefix.config, prefix.components`). ✅
- AC3: ZIP export and downloaded CSS properly wrap the files. ✅

**Status:** 🟢 Done — Sprint 3

---

## Sprint 4 — UI Fixes, NanoCSS Integration & Refinement · _Closed_

> **Sprint Goal:** Address all newly discovered snags, UI/UX issues, and complete the self-hosting nanoCSS transition.
> **Sprint Dates:** 2026-05-23 → 2026-06-06
> **Sprint Capacity:** 20 story points · **Delivered:** 14 pts (UC-015 carried, UC-019 partial)

---

### UC-013 · Corporate Preset Default & Live Preview Migration · 🟥 Must Have · 3 pts · 🟢 Done

**As an** indie developer,
**I want** the "Corporate" preset to be the default and the live preview positioned on the config page,
**so that** the app landing page focuses on a Hero Banner and configuration happens in context.

**Acceptance Criteria:**
- AC1: Use "Corporate" preset as the default configuration form values. ✅ (see ADR-004)
- AC2: Remove Live Preview block from Landing page, use it on Config page. ✅
- AC3: First element on the Landing page must be a Hero Banner. ✅

**Status:** 🟢 Done — Sprint 4

---

### UC-015 · Complete NanoCSS Self-Hosting (Remove Custom Chrome) · 🟥 Must Have · 5 pts · 🔴 Carried

**As an** indie developer,
**I want** the app to use its own generated nanoCSS framework for all interface styling,
**so that** we rely purely on our framework without custom chrome or inline styles.

**Acceptance Criteria:**
- AC1: Remove all inline styles from the app. 🔴 — 81 inline `style=` attributes remain in views (see UC-034)
- AC2: Use the compiled `nanocss.css` from `app/assets/stylesheets/nanocss-compiled/`. ✅ (`compile_default_nanocss` before-action in `ApplicationController`)
- AC3: Use nanoCSS components for the app interface (no custom ones). 🔴 — chrome still uses bespoke `.top-nav`, `.glass-panel`, `.configure-layout` etc. (see UC-036)
- AC4: Allow minimal tweaks in `application.css/scss` *only after* importing/compiling nanoCSS. 🟡
- AC5: Separate config page styling from Live Preview styling using the `@layer` directive. ✅

**Status:** 🔴 Carried — split into UC-034, UC-035, UC-036 (Sprint 8 — the user's "deep dogfooding" sprint)

---

### UC-016 · Quick Update Stylesheet Reload · 🟧 Should Have · 3 pts · 🟢 Done

**As an** indie developer,
**I want** the QuickUpdate function to change/reload the site's stylesheet file,
**so that** it doesn't just replace the contents of an inline `<style>` tag.

**Acceptance Criteria:**
- AC1: Clicking QuickUpdate updates a `<link rel="stylesheet">` (`href` is replaced — browser refetches). ✅
- AC2: New endpoint `GET /themes/css?theme=…&preview=true` serves the scoped, layered CSS. ✅

**Status:** 🟢 Done — Sprint 4 (see ADR-003; one stale spec to repair in UC-026)

---

### UC-017 · Fix Live Preview Contrast Bug · 🟥 Must Have · 2 pts · 🟢 Done

**As a** user,
**I want** the text in the live preview to remain visible when config changes,
**so that** I can read what I am styling.

**Acceptance Criteria:**
- AC1: Fix the issue where text changes to background colour when config is updated. ✅
- AC2: Remove or adjust the hardcoded overrides in App-level Tokens inside `:root` of `application.css`. ✅

**Status:** 🟢 Done — Sprint 4

---

### UC-018 · Fix Copy/Share Link · 🟥 Must Have · 2 pts · 🟢 Done

**As a** user,
**I want** the copy/share link to correctly encode and decode theme settings,
**so that** I can share my themes reliably.

**Acceptance Criteria:**
- AC1: Round-trip encode → URL → decode works for all currently shipped attributes (incl. `font_code`, `excluded_components`, `wrap_in_layer`). ✅
- AC2: Malformed `?theme=` falls back to defaults silently. ✅

**Status:** 🟢 Done — Sprint 4

---

### UC-019 · Component Catalogue Enhancements & Responsive Test Page · 🟧 Should Have · 5 pts · 🟡 Partial

**As an** indie developer,
**I want** a consistent, responsive component catalogue and a dedicated test page,
**so that** I can verify all components in a natural layout.

**Acceptance Criteria:**
- AC1: Fix visual nightmare on component catalogue. 🟡 — header/footer consistency landed; navbar spanning + contrast issues remain (UC-033)
- AC2: Ensure all nanoCSS components are responsive. 🔴 — covered by UC-033
- AC3: Create a test page with all components in their natural place with dummy copy and image placeholders. ✅ (`GET /components/test`)

**Status:** 🟡 Partial — full responsiveness sweep in UC-033 (Sprint 7)

---

### UC-020 · Dynamic Font Rendering in Google Fonts API · 🟦 Nice to Have · 3 pts · 🟢 Done

**As a** user,
**I want** each font name in the selection list to display in its own font style,
**so that** I can preview the font visually before selecting it.

**Acceptance Criteria:**
- AC1: Each font name in the dropdown applies its own `font-family` style. ✅

**Status:** 🟢 Done — Sprint 4

---

## Sprint 5 — Extensibility & Theming · _Closing 2026-04-25_

> **Sprint Goal:** Introduce default SVG icons and a floating theme-switcher component to allow users to toggle themes/modes on the fly.
> **Sprint Dates:** 2026-06-06 → 2026-06-20 (revised from original Sprint 5 dates)
> **Sprint Capacity:** 8 story points · **Delivered:** 8 pts

---

### UC-021 · Default Icon Set (nanoCSS Icons) · 🟧 Should Have · 5 pts · 🟢 Done

**As an** indie developer,
**I want** a default set of lightweight SVG icons built into the framework,
**so that** I don't have to hunt for third-party icon libraries for common UI needs.

**Acceptance Criteria:**
- AC1: ~20 minimal, cohesive SVG icons authored. ✅
- AC2: Exposed via `NanoIconHelper#nano_icon(:name)` — inherits `currentColor` and supports any `font-size`. ✅
- AC3: "Icons" section added to the Component Catalogue. ✅

**Status:** 🟢 Done — Sprint 5

---

### UC-022 · Floating Theme Switcher Component · 🟧 Should Have · 3 pts · 🟢 Done

**As a** user,
**I want** a floating, expandable/collapsible menu component,
**so that** I can easily toggle between Light/Dark mode and switch between preset themes.

**Acceptance Criteria:**
- AC1: `<prefix>-theme-switcher` component fixed to the bottom right of the viewport. ✅
- AC2: Collapsible/expandable using semantic `<details>/<summary>`. ✅
- AC3: Toggles `data-theme="dark"` on `<html>` and switches active preset variables; persists to `localStorage`. ✅

**Status:** 🟢 Done — Sprint 5

---

# ⏭ FORWARD ROADMAP — Sprints 6 to 10

> The four sprints below were drafted at Sprint 5 close, after a code-review
> revealed gaps between the design documents and the shipped product. They are
> arranged so the user's stated priorities (validation, framework polish &
> responsiveness, deep dogfooding) come first.

---

## ✅ Sprint 6 — Validation Enforcement & Spec Compliance · CLOSED 2026-05-03

> **Sprint Goal:** Close the gap between the validators we *defined* in Sprint 1 and the validators we *enforce*. Bring the test suite back to green.
> **Result:** ACHIEVED — 10/10 pts · All 5 stories shipped · 85/85 specs green

---

### UC-023 · Wire Validation Gate Into Controller · 🟥 Must Have · 3 pts · 🟢 Done

**As a** site operator,
**I want** invalid form submissions rejected before they hit the SCSS compiler,
**so that** we get a clear 422 instead of a Sass crash or silent fallback.

**Acceptance Criteria:**
- AC1: `ThemesController#preview` and `#download` call `ThemeConfiguration#valid?` before invoking `ScssCompilerService`.
- AC2: When invalid, the controller renders the form with `errors.full_messages` (HTML) or returns 422 with a JSON error body (Turbo Stream).
- AC3: A new spec exercises every validator (hex regex, prefix regex, prefix max length, font whitelist).

**Dependencies:** None
**Status:** 🟢 Done — Sprint 6

---

### UC-024 · Strict Prefix Length Validator · 🟥 Must Have · 1 pt · 🟢 Done

**As a** site operator,
**I want** the prefix capped at 32 characters (per PRD §8),
**so that** generated CSS variable names stay readable and within Sass identifier limits.

**Acceptance Criteria:**
- AC1: `validates :prefix, length: { maximum: 32 }` is added.
- AC2: Spec asserts a 33-character prefix is rejected.

**Status:** 🟢 Done — Sprint 6

---

### UC-025 · Preset Authoring Tidy · 🟧 Should Have · 2 pts · 🟢 Done

**As an** indie developer,
**I want** the three preset cards on the landing page to remain Corporate / Playful / Minimalist with a clean palette each,
**so that** the Quick Apply UX stays predictable.

**Acceptance Criteria:**
- AC1: Corporate stays as the form-load default (per ADR-004). The other two presets are reviewed for palette quality.
- AC2: Preset definitions live in a single `config/presets.yml` (or similar), not scattered in views.
- AC3: Adding a new preset requires only editing that file plus an icon — no controller change.

**Status:** 🟢 Done — Sprint 6

---

### UC-026 · Repair Failing Specs · 🟥 Must Have · 2 pts · 🟢 Done

**As a** developer,
**I want** the four currently-failing specs updated to match the shipped reality,
**so that** CI is green and we trust the suite.

**Acceptance Criteria:**
- AC1: `theme_configuration_spec.rb:72` — update default-colour expectation from `#3b82f6` to `#1e40af` (Corporate, per ADR-004).
- AC2: `theme_configuration_spec.rb:148` and `:154` — same root cause; update to Corporate defaults.
- AC3: `themes_spec.rb:42` — update preview expectation from inline `<style>` to `<link rel="stylesheet" href="/themes/css?…">` swap (per ADR-003).
- AC4: After UC-023 lands, add new specs for the validation gate.

**Status:** 🟢 Done — Sprint 6

---

### UC-027 · Harmony Swatch XSS Hardening · 🟧 Should Have · 2 pts · 🟢 Done

**As a** site operator,
**I want** the harmony swatch buttons to set form values via Stimulus event binding,
**so that** we eliminate the inline `onclick="…'<%= … %>'…"` attribute interpolation in `_harmony_options.html.erb`.

**Acceptance Criteria:**
- AC1: Replace inline `onclick` with `data-action`/`data-controller` Stimulus wiring.
- AC2: Remove the only ERB → JS string interpolation in the codebase.
- AC3: Existing system spec for harmony swatches still passes.

**Status:** 🟢 Done — Sprint 6

---

## Sprint 7 — NanoCSS Framework Polish, Responsiveness & Obsidian Capture _(Planned)_

> **Sprint Goal:** _(User-mandated.)_ Nail down the actual product — the nanoCSS styles, classes, components, and responsiveness. Fix the dropdown-in-navbar bug, fix the mobile navbar, deliver the responsiveness sweep, and refactor the monolithic component partial. **Crucially: capture the Obsidian glass-morphism theme as a fully-wired preset (UC-046) before Sprint 8 strips the custom chrome that currently defines it.**
> **Sprint Dates (proposed):** 2026-05-09 → 2026-05-23
> **Estimated Capacity:** 26 story points

---

### UC-028 · Fix Dropdown Inside Navbar · 🟥 Must Have · 3 pts · 🟢 Done

**As a** user,
**I want** a dropdown placed inside a navbar to stay open while I interact with its items,
**so that** I can actually use the menu.

**Acceptance Criteria:**
- AC1: Open the catalogue test page, click a dropdown trigger inside `.{prefix}-nav`, click any menu item — the menu was not closed during the click.
- AC2: Click outside closes the menu (existing behaviour preserved).
- AC3: Keyboard nav (`Esc`, `Tab`) works inside a navbar-hosted dropdown.
- AC4: Capybara system spec covers the regression.

**Dependencies:** None
**Status:** 🟢 Done — Sprint 9 (2026-05-05)

---

### UC-029 · Mobile Navbar · 🟥 Must Have · 5 pts · 🟢 Done

**As a** user on a phone,
**I want** the navbar to collapse into a hamburger menu and expand smoothly,
**so that** I can navigate the site below 768 px.

**Acceptance Criteria:**
- AC1: Below the `--{prefix}-breakpoint-md` threshold, primary nav items collapse behind a hamburger toggle.
- AC2: The expanded panel is full-width, scrollable, and accessible (focus-trapped, ESC-closable).
- AC3: Layout works at 320 px viewport width without horizontal scroll.
- AC4: Capybara system spec at 375 px and 1280 px viewports both pass.

**Dependencies:** None
**Status:** 🟢 Done — Sprint 9 (2026-05-05)

---

### UC-030 · Prefix Breadcrumb & Tooltip Components · 🟧 Should Have · 2 pts · 🟢 Done

**As an** indie developer following FR-011,
**I want** every component selector prefixed with my chosen namespace,
**so that** nanoCSS cannot collide with my host application.

**Acceptance Criteria:**
- AC1: Breadcrumb selector changes from `nav[aria-label="breadcrumb"]` to `.{prefix}-breadcrumb` (markup updated, fallback aria attribute preserved).
- AC2: Tooltip selector changes from `[data-tooltip]` to `.{prefix}-tooltip` (or `[data-{prefix}-tooltip]`).
- AC3: Component Catalogue snippets reflect the new prefixed selectors.

**Status:** 🟢 Done — Sprint 9 (2026-05-05)

---

### UC-031 · Tier 1 Dark Mode (`prefers-color-scheme`) · 🟧 Should Have · 2 pts · 🟢 Done

**As a** user with system-level dark mode,
**I want** nanoCSS to honour my OS preference unless I have explicitly chosen a mode,
**so that** the site matches the rest of my desktop.

**Acceptance Criteria:**
- AC1: A `@media (prefers-color-scheme: dark) { :root { … } }` block emits the dark-mode tokens.
- AC2: An explicit `[data-theme="light"]` or `[data-theme="dark"]` overrides the media query (Tier 2).
- AC3: The Theme Switcher persists the explicit choice in `localStorage` (Tier 3 — already shipped).

**Status:** 🟢 Done — Sprint 9 (2026-05-05)

---

### UC-032 · Modular Component Partials · 🟧 Should Have · 5 pts · 🟢 Done

**As a** maintainer,
**I want** `_components.scss` split into `components/_button.scss`, `_nav.scss`, `_card.scss`, etc.,
**so that** the per-component opt-out (UC-010) becomes a clean partial-include list rather than a brittle regex strip.

**Acceptance Criteria:**
- AC1: `app/assets/stylesheets/nanocss/components/_*.scss` — one file per component.
- AC2: `_components.scss` reduced to an `@use` index.
- AC3: `ScssCompilerService` exclusion logic replaced with an include-list driven by `ThemeConfiguration#excluded_components`.
- AC4: ZIP export ships the modular tree.
- AC5: All existing specs still pass.

**Status:** 🟢 Done — Sprint 9 (2026-05-05)

---

### UC-033 · Responsiveness Sweep Across All 20 Components · 🟥 Must Have · 4 pts · 🟢 Done

**As a** user,
**I want** every component to look and behave correctly from 320 px to 1920 px viewport,
**so that** nanoCSS earns the "responsive by default" promise.

**Acceptance Criteria:**
- AC1: Each of the 20 components on `/components/test` is verified at 320 / 768 / 1280 / 1920 viewports.
- AC2: A snapshot/visual-regression artefact (single PNG per breakpoint) is attached to the sprint review.
- AC3: Any component with a layout failure has its fix landed in this sprint or a follow-up issue raised.

**Status:** 🟢 Done — Sprint 9 (2026-05-05)

---

### UC-046 · Obsidian Preset (Glass-Morphism Capture) · 🟧 Should Have · 5 pts · 🟡 Partial

> _See full specification above under the Sprint 8 section where it was originally drafted — moved here to Sprint 7 to ensure the values are captured before Sprint 8 strips the source files._

**Dependencies:** UC-025 (preset config), UC-032 (ideally — modular partials make component edits cleaner)
**Must complete before:** UC-034, UC-036 (Sprint 8) — the source CSS it reads will be deleted in those UCs
**Status:** 🟢 Done — Sprint 9 (2026-05-05)

---

## Sprint 8 — Deep Dogfooding + Sprint 7 Regressions _(Planned)_

> **Sprint Goal:** Fix four visual regressions surfaced in Sprint 7 QA (UC-047–UC-050), then begin deep dogfooding. Quick Apply must visibly re-skin the app. Replace custom chrome with nanoCSS components. Strip inline styles.
> **Sprint Dates (proposed):** 2026-05-23 → 2026-06-06
> **Estimated Capacity:** 26 pts (capacity raised — regression fixes prepend the original 18 pts)

---

### UC-047 · Fix Dark Mode Theme-Switcher Regression · 🟥 Must Have · 1 pt · 🟢 Done

**As a** user toggling between light and dark mode,
**I want** the "Toggle Dark Mode" button to reliably switch both ways,
**so that** I can choose a mode regardless of my OS setting.

**Regression from:** UC-031 — the new `@media (prefers-color-scheme: dark)` tier means removing `data-theme` leaves the OS query in control, so "return to light" on a dark-OS machine is broken.

**Acceptance Criteria:**
- AC1: Clicking "Toggle Dark Mode" from light → sets `data-theme="dark"` on `<html>`. Clicking again → sets `data-theme="light"` (explicitly, not remove-attribute). The `data-theme` attribute is always set after the first toggle.
- AC2: On an OS with dark mode, the page still starts in dark, and toggling "light" explicitly sets `[data-theme="light"]` so the Tier-2b rule overrides the media query.
- AC3: System spec covers the toggle round-trip; existing `theme_switcher_spec.rb` updated to match.

**Root cause:** `theme_controller.js#toggleDark` calls `removeAttribute("data-theme")` instead of `setAttribute("data-theme", "light")`.

**Status:** 🟢 Done — Sprint 8 (2026-05-04)

---

### UC-048 · Fix Dark-Mode Contamination of Component Catalogue · 🟥 Must Have · 2 pts · 🟢 Done

**As a** developer browsing the Component Catalogue,
**I want** component previews to always render in light mode,
**so that** I can evaluate the components without OS dark mode distorting the render.

**Regression from:** UC-031 — `@media (prefers-color-scheme: dark) { :root { ... } }` inverts the neutral token scale globally. On any machine with OS dark mode, catalogue cards show dark-on-dark text and dark backgrounds.

**Acceptance Criteria:**
- AC1: Component Catalogue (`/components`) renders with correct light-mode neutral colours regardless of the user's OS dark-mode setting.
- AC2: The app chrome still responds to OS dark mode (that is correct behaviour and must not regress).
- AC3: System spec asserts `.nanocss-card` on the catalogue page does not produce invisible text at any viewport.

**Fix approach:** Add `data-theme="light"` to the `<body>` of pages that include the nanoCSS framework style (or scope dark mode so it only applies when the user has explicitly chosen it via the Theme Switcher).

**Status:** 🟢 Done — Sprint 8 (2026-05-04)

---

### UC-049 · Fix Hero `color: #fff` Cascade · 🟥 Must Have · 1 pt · 🟢 Done

**As a** developer using the Component Catalogue and live preview,
**I want** `.{prefix}-hero` to not force white text on child components,
**so that** text inside nested components is readable.

**Regression from:** UC-046 — added `color: #fff` to `.{prefix}-hero` for gradient legibility; this value cascades to all child elements including components embedded inside the hero in the preview pane.

**Acceptance Criteria:**
- AC1: `.{prefix}-hero > *` inherits white text only on the direct text nodes inside the hero wrapper, not on nested components.
- AC2: A card or nav placed inside `.{prefix}-hero` maintains its own text colour.
- AC3: Hero text itself remains light/white against the gradient (the original purpose of the change is preserved).

**Fix approach:** Replace `color: #fff` with a more scoped rule: `color: var(--{prefix}-neutral-50, #f9fafb)` on `h1, h2, h3, p` direct children only, or wrap the hero text in a specific selector.

**Status:** 🟢 Done — Sprint 8 (2026-05-04)

---

### UC-050 · Fix Live Preview — Body Font + Breadcrumb Rendering · 🟥 Must Have · 2 pts · 🟢 Done

**As a** developer previewing a theme,
**I want** all font and component changes to appear immediately in the live preview,
**so that** what I configure is what I see.

**Two defects to fix:**

**Defect A — Body font not updating:**
Changing `font_body` on the configure form does not update the live-preview body text font. The preview likely re-scopes only heading/subtitle font imports or the scoped compile path omits the font-body custom property re-emit.

**Defect B — Breadcrumb broken in preview:**
The breadcrumb component in the live preview shows broken styling. Likely cause: the backward-compat `nav[aria-label="breadcrumb"]` selector in `_breadcrumbs.scss` picks up conflicting styles from the scoped preview context (the configurator's own nav is also a `<nav>` element), OR the scoped compilation strips or reorders the breadcrumb rule unexpectedly.

**Acceptance Criteria:**
- AC1: Changing `font_body` and clicking "Preview" updates the body-text font in the `#preview-canvas` pane.
- AC2: The breadcrumb component in the live preview renders with visible separator characters and correct text/background contrast.
- AC3: System spec covers both ACs with a Turbo Stream interaction.

**Status:** 🟢 Done — Sprint 8 (2026-05-04)

---

### UC-034 · Eliminate Inline Styles in App Views · 🟥 Must Have · 5 pts · 🟢 Done

**As a** maintainer,
**I want** zero inline `style="…"` attributes in `app/views/`,
**so that** the visible app obeys the nanoCSS stylesheet rather than overriding it.

**Acceptance Criteria:**
- AC1: 81 → 0 inline-style occurrences across `app/views/**`.
- AC2: Replacements use nanoCSS utility classes (`.{prefix}-stack`, `.{prefix}-grid-*`, `.{prefix}-text-muted`, etc.).
- AC3: A RuboCop or Brakeman rule fails CI if a new inline `style=` is introduced.

**Status:** 🟢 Done — Sprint 8 (2026-05-04). Lint spec at `spec/lint/inline_styles_spec.rb` enforces the rule in CI.

---

### UC-035 · Quick Apply Visibly Re-skins the App Chrome · 🟥 Must Have · 5 pts · 🟢 Done

**As a** user clicking "Apply Corporate" / "Apply Playful" / "Apply Minimalist" on the landing page,
**I want** the app's chrome (top nav, sidebar, footer, hero) to immediately reflect that preset,
**so that** the dogfooding promise is real and I can evaluate the framework instantly.

**Acceptance Criteria:**
- AC1: The `<link>` swap (already shipped) updates *both* the `#nanocss-preview` scoped stylesheet *and* the unscoped chrome stylesheet at `app/assets/stylesheets/nanocss-compiled/nanocss.css`.
- AC2: The chrome stylesheet imports unscoped nanoCSS so changing primary/secondary/tertiary visibly retints the navbar, hero, buttons, and links.
- AC3: Capybara system spec: from a vanilla landing page, click "Apply Playful" → primary brand colour visible in the navbar background changes within 500 ms.

**Dependencies:** UC-034, UC-036
**Status:** 🟢 Done — Sprint 8 (2026-05-04). Turbo Stream in `preview.turbo_stream.erb` replaces `#nanocss-framework-style` on landing page Quick Apply.

---

### UC-036 · Replace Custom Chrome With nanoCSS Components · 🟥 Must Have · 5 pts · 🟢 Done

**As a** maintainer,
**I want** the app's top navigation, sidebar/configure layout, and hero replaced with the framework's own `<prefix>-nav`, `<prefix>-card`, `<prefix>-hero` components,
**so that** what we ship is what we use.

**Acceptance Criteria:**
- AC1: `.top-nav` markup replaced with `<nav class="{prefix}-nav …">`.
- AC2: `.glass-panel`, `.configure-layout`, and other bespoke blocks replaced with nanoCSS components or utility compositions.
- AC3: `application.css` shrinks to layout shims only — no overrides of nanoCSS tokens.

**Status:** 🟢 Done — Sprint 8 (2026-05-04). `.top-nav` replaced with `nanocss-nav`; `.glass-panel` and `.nav-links` rules removed; layout shims retained.

---

### UC-046 · Obsidian Preset (Glass-Morphism Capture) · 🟧 Should Have · 5 pts · 🟡 Partial

**As an** indie developer who likes the look of the configurator's current chrome,
**I want** that entire aesthetic — deep navy gradients, smoked-glass surface blur, luminous border glow, and oversized hero typography — captured as a fourth nanoCSS preset called **Obsidian**,
**so that** the visual identity is preserved as a first-class swappable preset, and the dogfooding work in UC-035/UC-036 has a concrete visual regression target.

> **Important context — tokens vs. component implementation:**
> A preset only changes `ThemeConfiguration` variables (tokens). For Obsidian's gradient hero, glass surfaces, and card typography to actually respond to a preset swap, the *component SCSS must reference those tokens* — not bypass them with hardcoded values. This UC therefore has two jobs: (1) define the tokens, and (2) audit + fix the components to consume them.

**Acceptance Criteria:**

**Part A — Extend `ThemeConfiguration` with glass-surface tokens:**
- AC1: Three new optional tokens added to `ThemeConfiguration` covering glass-surface effects. Defaults for non-glass presets are neutral (no-op). Obsidian values are:
  - `surface_blur` — e.g. `12px` (the `backdrop-filter: blur(…)` radius on panels)
  - `surface_opacity` — e.g. `0.15` (the alpha of the glass background fill)
  - `border_glow_alpha` — e.g. `0.25` (the opacity of the luminous panel edge)
- AC2: `ThemeConfiguration#to_scss_variables_string` emits `$nanocss-surface-blur`, `$nanocss-surface-opacity`, `$nanocss-border-glow-alpha` with the new values.
- AC3: Base64 round-trip includes the new tokens; `from_base64` falls back gracefully when they are absent (backwards-compatible with existing share links).

**Part B — Capture and register the Obsidian preset:**
- AC4: An `obsidian` entry is added to `config/presets.yml` (per UC-025) with:
  - Primary, secondary, tertiary colours extracted verbatim from the current `application.css` / `--app-primary` etc.
  - All three new surface tokens (AC1 values)
  - Shadow matrix values extracted from current `.glass-panel` box-shadow declarations
  - Typography anchor values matching the current chrome's scale
- AC5: A fourth preset card — **Obsidian** — renders on the landing page alongside Corporate / Playful / Minimalist. The card's preview tile uses the Obsidian palette and a glass-morphism surface so the aesthetic is communicated before the user clicks.

**Part C — Audit and wire components to consume the new tokens:**
- AC6: **Hero component** — gradient uses `var(--{prefix}-primary)` → `var(--{prefix}-secondary)` as gradient stops. Swapping to Corporate (a light preset) visibly re-colours the hero gradient; swapping to Obsidian restores the deep navy. Remove any hardcoded hex values from the Hero's gradient declaration.
- AC7: **Card component headers** — investigate where the oversized card-header typography on the landing page comes from:
  - If inline `style=` attributes → they are removed by UC-034 (already scheduled). In this UC, add the correct typography rule to the Card component SCSS using the `$nanocss-base-typography` scale variable so the size is preserved through the refactor.
  - If hardcoded `px` / `rem` values in `_components.scss` → replace with the typography scale variable (`calc(var(--{prefix}-text-base) * 1.5)` or equivalent).
- AC8: **Glass panels (`.{prefix}-card`, `.{prefix}-nav`)** — add `backdrop-filter: blur(var(--{prefix}-surface-blur, 0))` and a `background-color` that incorporates `var(--{prefix}-surface-opacity, 1)` as the alpha channel. When `surface_blur` is `0` and `surface_opacity` is `1`, the component looks like a standard opaque panel (correct for Corporate/Playful/Minimalist). When set to Obsidian values, it becomes glass.

**Part D — Visual regression:**
- AC9: Once UC-035 + UC-036 land, applying **Obsidian** via Quick Apply on a fresh page load must produce chrome that is visually indistinguishable from the pre-Sprint-8 custom chrome. A side-by-side screenshot artefact (before/after) is attached to the sprint review.
- AC10: Spec — system spec navigates to `/`, clicks "Apply Obsidian", asserts the navbar's computed background includes the Obsidian primary colour and that the hero element has a gradient property.

**Dependencies:**
- UC-025 (presets externalised to `config/presets.yml`) — must land first
- UC-032 (modular `_components.scss`) — ideally precedes this so component edits touch isolated files; can proceed against monolith if UC-032 slips
- UC-034/UC-036 (chrome refactored to nanoCSS) — required before AC9 can be measured

**Placement:** Sprint 7 (end of sprint — capture and extend tokens *before* Sprint 8 begins stripping the source files)
**Status:** 🟢 Done — Sprint 9 (2026-05-05)

**Implementation Note:**
The values to capture are currently in `app/assets/stylesheets/application.css` and the `.glass-panel` / `.top-nav` rules. **Extract them verbatim first — do not improve or redesign.** Aesthetic refinement is a follow-up UC if needed. The goal is fidelity: apply Obsidian and it must look exactly like the app does today.

---

### UC-037 · Theme Switcher Lives In The Chrome · 🟦 Nice to Have · 3 pts · 🟢 Done

**As a** user,
**I want** the floating Theme Switcher (UC-022) available on every page of the app,
**so that** I can flip Light/Dark and preview presets while I'm configuring.

**Acceptance Criteria:**
- AC1: Theme Switcher mounted in the application layout, not just the test page.
- AC2: Switcher is suppressed on `/themes/configure` to avoid colliding with the form (or coordinated — TBD by UX).

**Status:** 🟢 Done — Sprint 8 (2026-05-04). Mounted in `application.html.erb`; suppressed on `configure_path` via `unless` guard.

---

## Sprint 9 — Harmony Completion & Build Polish _(Planned)_

> **Sprint Goal:** Close the FR-006 harmony gap, replace the placeholder "minifier" with a real one, and add the catalogue sidebar.
> **Sprint Dates (proposed):** 2026-06-06 → 2026-06-20
> **Estimated Capacity:** 11 story points

---

### UC-038 · Monochromatic + Split-Complementary Harmonies · 🟧 Should Have · 3 pts · 🟢 Done

**As an** indie developer,
**I want** the two remaining FR-006 harmonies (Monochromatic, Split-Complementary),
**so that** I have the full five-strategy palette generator the PRD promised.

**Acceptance Criteria:**
- AC1: `ColourHarmonyService::HARMONIES` extended to include `:monochromatic` and `:split_complementary`.
- AC2: Per-algorithm specs cover an edge case (greyscale primary, near-white primary).
- AC3: `_harmony_options.html.erb` renders the new swatch rows.

**Status:** 🟢 Done — Sprint 9 (2026-05-05)

---

### UC-039 · Component Catalogue Sidebar Navigation · 🟧 Should Have · 3 pts · 🟢 Done

**As a** developer browsing the catalogue,
**I want** a sticky sidebar listing every component as a jump link,
**so that** I can navigate the long page without scrolling.

**Acceptance Criteria:**
- AC1: Sidebar nav with anchor links for all 20 components.
- AC2: Active section highlighted via `IntersectionObserver`.
- AC3: Sidebar collapses below the mobile breakpoint (UC-029 dependency).

**Status:** 🟢 Done — Sprint 9 (2026-05-05)

---

### UC-040 · Real CSS Minification · 🟧 Should Have · 2 pts · 🟢 Done

**As an** indie developer downloading the ZIP,
**I want** `nanocss.min.css` to be a correctly-minified stylesheet,
**so that** I can drop it into production without re-running a minifier.

**Acceptance Criteria:**
- AC1: `ZipAssemblerService` produces `nanocss.min.css` via a *second* `Sass.compile_string(source, style: :compressed)` call, not `gsub(/\s+/, ' ')`.
- AC2: The minified file passes a CSS lint round-trip (re-parse, re-emit, no diff in semantics).
- AC3: Spec asserts file size delta vs un-minified is ≥ 30 %.

**Status:** 🟢 Done — Sprint 9 (2026-05-05)

---

### UC-041 · Validate Generated CSS Against W3C Validator · 🟦 Nice to Have · 3 pts · 🟢 Done

**As a** maintainer,
**I want** a CI step that runs the generated CSS through `css-validator`,
**so that** we catch malformed output before users do.

**Acceptance Criteria:**
- AC1: GitHub Action fetches `https://jigsaw.w3.org/css-validator/validator?profile=css3svg&output=json` for a default-config compile.
- AC2: Build fails on validation errors.

**Status:** 🟢 Done — Sprint 9 (2026-05-05)

---

## Sprint 8 QA Findings — Untriaged _(Awaiting Sprint Assignment)_

> Logged 2026-05-05 after visual QA review. Not yet assigned to a sprint.
> UC-051/052/054 are regressions or long-standing bugs. UC-053 is a new feature request.

---

### UC-051 · Fix Light Mode — Dark Background Persists on Homepage & Catalogue · 🟥 Must Have · 2 pts · ⚪ To Do

**As a** user toggling to light mode,
**I want** the homepage and components page to switch to a light background,
**so that** the app genuinely responds to my theme choice on every page.

**Observed:** Toggling Theme Switcher → Light leaves the homepage hero + preset section and the components catalogue page with the dark/obsidian navy background.

**Acceptance Criteria:**
- AC1: `data-theme="light"` on `<html>` causes the homepage body/hero background to switch to the light-mode neutral token (no dark navy).
- AC2: The component catalogue page (`/components`) also responds correctly — no dark background in light mode.
- AC3: System spec: navigate to `/`, toggle to light, assert body background is not the dark navy token.

**Root cause (suspected):** Background colour for the hero/page is hardcoded or uses a token not overridden by the `[data-theme="light"]` Tier-2b rule.

**Dependencies:** UC-031, UC-047/048 (landed; verify interaction)
**Status:** 🟢 Done — Sprint 9 (2026-05-05)

---

### UC-052 · Fix Dark Mode Card Contrast — Body Text and Background Too Similar · 🟥 Must Have · 1 pt · ⚪ To Do

**As a** user in dark mode,
**I want** card body text to be clearly readable against the card background,
**so that** the dark theme is usable, not just visually distinct.

**Observed:** In dark mode, card body text and card background are too close in value — text is difficult to read.

**Acceptance Criteria:**
- AC1: `.{prefix}-card` body text achieves at least 4.5:1 contrast ratio against the card background in dark mode (WCAG 2.1 AA).
- AC2: Fix applies across all four presets' dark-mode token sets.
- AC3: Spec asserts the contrast-critical text colour token is not the same as the card background token in dark mode.

**Status:** 🟢 Done — Sprint 9 (2026-05-05)

---

### UC-053 · Expose Navbar Glass Morphism as a nanoCSS Utility Class · 🟧 Should Have · 2 pts · ⚪ To Do

**As an** indie developer,
**I want** the app's glass-blur navbar effect available as a reusable nanoCSS class,
**so that** I can apply the same translucent surface treatment to any element in my project.

**Background:** The app's top navbar uses a distinctive translucent blur effect (backdrop-filter + semi-transparent background + subtle border). This is a widely desired aesthetic that should be a first-class framework primitive, separate from the Obsidian preset's glass tokens.

**Acceptance Criteria:**
- AC1: A `.{prefix}-glass` utility class added to the nanoCSS SCSS — applies `backdrop-filter: blur(var(--{prefix}-surface-blur, 8px))`, a semi-transparent background using `surface_opacity`, and a subtle luminous border.
- AC2: The navbar itself (`nanocss-nav` in `application.html.erb`) is refactored to use `.{prefix}-glass` rather than bespoke CSS, so the dogfooding is real.
- AC3: `.{prefix}-glass` is documented in the Component Catalogue with an example panel.
- AC4: On presets without glass tokens (Corporate, Playful, Minimalist), the class degrades gracefully (no backdrop-filter, standard opaque background).

**Status:** 🟢 Done — Sprint 9 (2026-05-05)

---

### UC-054 · Fix Quick Apply in Floating Theme Switcher — Must Re-Skin Current Page · 🟥 Must Have · 3 pts · ⚪ To Do

**As a** user on any page of the app,
**I want** the preset buttons in the floating Theme Controls to immediately re-skin the page I'm on,
**so that** I can preview presets from the catalogue, configure page, or anywhere — not just the landing page.

**Observed:** Clicking a preset in the floating Theme Controls currently navigates to the configure page (or does nothing useful). The preset is never applied to the current page's chrome.

**Required behaviour:** Same mechanism as the landing page Quick Apply — swap the `#nanocss-framework-style` link tag via a Turbo Stream, keeping the user on their current page. No navigation.

**Acceptance Criteria:**
- AC1: Clicking any preset button in the floating Theme Switcher re-skins the chrome on the current page (landing, catalogue, or configure) without navigation.
- AC2: The re-skin applies within 500 ms and updates the same `#nanocss-framework-style` link already used by the landing page Quick Apply.
- AC3: The active preset is visually indicated in the switcher (e.g., checked state or highlighted button).
- AC4: The chosen preset is persisted to `localStorage` so a page refresh retains it.
- AC5: System spec covers the interaction from the component catalogue page (`/components`) — the most important non-landing page.

**Root cause:** The floating Theme Switcher's preset buttons were wired to navigate to the configure page rather than to a dedicated Quick Apply endpoint. The Turbo Stream + `#nanocss-framework-style` swap (built for UC-035) was never hooked up to the Theme Switcher.

**Status:** 🟢 Done — Sprint 9 (2026-05-05)

---

## Sprint 10 — Deployment, Docs & Accessibility _(Planned)_

> **Sprint Goal:** Cross the line from "working locally" to "deployable to the IONOS VPS with a real runbook," replace the README, and run a formal WCAG 2.1 AA audit.
> **Sprint Dates (proposed):** 2026-06-20 → 2026-07-04
> **Estimated Capacity:** 11 story points

---

### UC-042 · Capistrano Deployment Runbook · 🟥 Must Have · 5 pts · ⚪ To Do

**As an** operator,
**I want** a documented, repeatable Capistrano flow targeting the IONOS AlmaLinux 9 VPS,
**so that** deployment is not a tribal-knowledge exercise.

**Acceptance Criteria:**
- AC1: `config/deploy.rb` + `config/deploy/{staging,production}.rb` complete and committed.
- AC2: `bin/deploy` wraps `cap production deploy` with pre-flight checks (asset-precompile, master-key present).
- AC3: A markdown runbook in `docs/DEPLOY.md` covers cold-start, rollback, and Passenger restart.

**Status:** 🟢 Done — Sprint 9 (2026-05-05)

---

### UC-043 · README Rewrite · 🟧 Should Have · 2 pts · ⚪ To Do

**As an** OSS visitor,
**I want** a `README.md` that explains what nanoCSS is, why it exists, and how to use both the SaaS and the downloaded framework,
**so that** the repo is self-explanatory.

**Acceptance Criteria:**
- AC1: README replaces the Rails default.
- AC2: Includes screenshots of the configurator, a curl-then-link example, and a "what's in the box" tree.

**Status:** 🟢 Done — Sprint 9 (2026-05-05)

---

### UC-044 · Active CHANGELOG Sync · 🟦 Nice to Have · 1 pt · ⚪ To Do

**As a** maintainer,
**I want** every merged PR to require a CHANGELOG entry under `## [Unreleased]`,
**so that** the changelog stops decaying.

**Acceptance Criteria:**
- AC1: PR template includes a CHANGELOG checkbox.
- AC2: A CI lint flags PRs that touch `app/` without touching `design/CHANGELOG.md`.

**Status:** 🟢 Done — Sprint 9 (2026-05-05)

---

### UC-045 · WCAG 2.1 AA Audit · 🟧 Should Have · 3 pts · ⚪ To Do

**As an** indie developer,
**I want** a documented audit confirming nanoCSS components and the configurator app meet WCAG 2.1 AA,
**so that** I can ship to clients with accessibility requirements.

**Acceptance Criteria:**
- AC1: axe-core / pa11y run against every page of the configurator and every component on `/components/test`.
- AC2: Each finding either fixed or recorded as a known limitation in `docs/ACCESSIBILITY.md`.
- AC3: Tinted semantic colours (UC-011 AC3) re-tested for contrast under all three default presets.

**Status:** 🟢 Done — Sprint 9 (2026-05-05)

---

## Icebox _(Unscheduled / Future)_

- **UC-IB-001:** Configurator account system (Devise + theme persistence) — explicitly *out of scope* per PRD §3.
- **UC-IB-002:** Tailwind / Bootstrap-style utility-class generator with arbitrary breakpoints.
- **UC-IB-003:** Figma plugin that consumes a base64 token and emits matching design tokens.
- **UC-IB-004:** CDN-served pre-built bundles for the three default presets.
