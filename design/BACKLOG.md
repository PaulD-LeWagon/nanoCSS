---
vc-id: 895acb54-d6d8-45b5-a91e-a735affb2eb8
---
# Product Backlog

> **Project:** nanoCSS
> **Last Updated:** 2026-04-11
> **Current Sprint:** 1 of 3
> **Sprint Cadence:** 2 weeks

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
| 🔴 Blocked     | Cannot proceed — blocker named below        |
| 🧊 Icebox      | Deferred to a future Sprint or indefinitely |

---

## Sprint 1 — The Core Engine & Customisation

> **Sprint Goal:** Deliver a stateless MVP where a user can configure a theme, preview it live via Hotwire, and download the compiled SCSS/CSS zip.
> **Sprint Dates:** 2026-04-11 → 2026-04-25
> **Sprint Capacity:** 25 story points

---

### UC-001 · Preset Theme & Live Preview · 🟥 Must Have · 5 pts

**As an** indie developer,
**I want to** select a preset theme and see it instantly,
**so that** I can quickly evaluate the framework without manual configuration.

**Acceptance Criteria:**
- AC1: Landing page displays three preset cards (Corporate, Playful, Minimalist). [system]
- AC2: Clicking a preset instantly applies it to the preview pane without a full page reload. [system]
- AC3: The `<style>` tag in the preview DOM updates within 200ms. [integration]

**Dependencies:** None
**UI Components:** `<ThemeCard>`, `<PreviewPane>`
**Status:** ⚪ To Do

---

### UC-002 · Custom Theme Configuration Form · 🟥 Must Have · 8 pts

**As an** indie developer,
**I want to** configure specific brand colours, fonts, and spacing,
**so that** the framework matches my exact design requirements.

**Acceptance Criteria:**
- AC1: Form exposes Basic Mode (anchor variables) and Advanced Mode (individual overrides). [unit]
- AC2: Switching modes retains previously entered values. [integration]
- AC3: Invalid hex codes (`#123` or `#zzz`) are rejected server-side. [unit]
- AC4: Valid inputs trigger a Hotwire Turbo Stream update to the preview pane. [system]
- AC5: Advanced Mode correctly decouples Margin Base from Spacing (Padding) Base in the generated SCSS variables.
- AC6: The UI form successfully captures and passes the 5-part Drop Shadow and Text Shadow matrices to the `ScssCompilerService`.
- AC7: The Google Fonts selector successfully applies the newly added Code Font selection to the `--nanocss-font-code` variable.

**Dependencies:** UC-001
**UI Components:** `<ConfigSidebar>`, `<ModeToggle>`, `<ColourPicker>`
**Status:** ⚪ To Do

---

### UC-003 · Download / Export Engine · 🟥 Must Have · 5 pts

**As an** indie developer,
**I want to** download my tailored framework as a .zip file,
**so that** I can drop it directly into my project.

**Acceptance Criteria:**
- AC1: Clicking "Download" streams a .zip file to the client within 2 seconds. [integration]
- AC2: The archive contains `nanocss.css`, `nanocss.min.css`, and a `scss/` directory. [unit]
- AC3: All SCSS variables and filenames respect the user's custom prefix. [unit]

**Dependencies:** UC-002
**UI Components:** `<DownloadButton>`
**Status:** ⚪ To Do
**Implementation Note for Agent:**
The core framework SCSS files (`_variables.scss`, `_mixins.scss`, `_utilities.scss`, and the component partials) have already been manually authored and placed in `/app/assets/stylesheets/nanocss/`. Do not recreate or alter these source files. Your task is to build the Ruby service that reads them, prepends the user's dynamic config, and compiles them.

---

### UC-004 · Shareable Theme URLs · 🟥 Must Have · 3 pts

**As an** indie developer,
**I want to** generate a URL encoding my configuration,
**so that** I can bookmark or share my theme without needing an account.

**Acceptance Criteria:**
- AC1: Clicking "Copy Share Link" copies a URL with a base64 encoded `?theme=` parameter. [system]
- AC2: Visiting a URL with a valid `?theme=` parameter pre-populates the config form and preview. [system]
- AC3: Edge case — malformed `?theme=` data gracefully falls back to the default theme. [unit]

**Dependencies:** UC-002
**UI Components:** `<ShareButton>`
**Status:** ⚪ To Do

---

## Sprint 2 — Refinement & Component Catalogue _(Planned)_

> _Use Cases scheduled for the next Sprint._

### UC-005 · Component Catalogue Reference · 🟥 Must Have · 5 pts

**As an** indie developer,
**I want to** browse all available components with their HTML/JS snippets,
**so that** I can easily copy-paste them into my project.

**Acceptance Criteria:**
- AC1: Dedicated page displays all 17 components with live renders. [system]
- AC2: Raw HTML snippets use the currently active namespace prefix. [unit]
- AC3: Clicking the copy icon copies the snippet to the clipboard and shows a toast. [system]

**Dependencies:** None
**Status:** ⚪ To Do

---

### UC-006 · Colour Harmony Generator · 🟧 Should Have · 3 pts

**As an** indie developer,
**I want to** receive automatic secondary/tertiary colour suggestions,
**so that** I can quickly build a cohesive palette based on my primary brand colour.

**Acceptance Criteria:**
- AC1: Entering a Primary hex suggests Complementary, Analogous, Triadic, etc., palettes. [unit]
- AC2: Clicking a suggestion populates the Secondary and Tertiary inputs. [system]

**Dependencies:** UC-002
**Status:** ⚪ To Do

---

## Sprint 3 — Typography, Layering, & Granular Control

> **Sprint Goal:** Fully integrate the Google Fonts API for dynamic typography, introduce granular per-component toggling, and implement auto-tinting for a polished v1.0 release.
> **Estimated Capacity:** 16 story points

---

### UC-014 · Google Fonts API Integration (FR-008) · 🟧 Should Have · 5 pts

**As an** indie developer,
**I want to** search and select from the Google Fonts catalogue directly within the config sidebar,
**so that** I can easily assign distinct typefaces to Headers, Subtitles, and Body Text without hunting for exact names.

**Acceptance Criteria:**
- AC1: `FontsController` fetches the font catalogue from the Google Fonts API, passing a JSON list to the frontend.
- AC2: Stimulus controllers power search and select dropdowns for: Headers, Subtitles, and Body Text.
- AC3: **Security (Strict):** The `ThemeConfiguration` backend model strictly validates that the selected font string exists in the known Google Fonts catalogue *before* interpolating it into an `@import url(...)` to prevent injection attacks or path traversal.
- AC4: The SCSS compiler injects the valid Google Fonts `@import` rule at the top of the generated CSS and sets the corresponding `--nanocss-font-*` CSS custom properties.

**Dependencies:** None
**UI Components:** `<FontSelectorDropdown>`
**Status:** ⚪ To Do

---

### UC-010 · Per-Component Toggle Selection · 🟧 Should Have · 5 pts

**As an** indie developer,
**I want to** explicitly select or exclude individual components (e.g., exclude Modals and Carousels),
**so that** I can minimise my CSS footprint to exactly what I need.

**Acceptance Criteria:**
- AC1: Configuration UI displays a dynamic list of checkboxes for components when the Standard or Full tier is activated.
- AC2: Deselected components are omitted from both the generated `nanocss.css` string and the compiled `scss/` ZIP folder.
- AC3: The preview gracefully handles missing components.

**Dependencies:** None
**UI Components:** `<ComponentToggleList>`
**Status:** ⚪ To Do

---

### UC-011 · Automated Semantic Colour Tinting (FR-007) · 🟧 Should Have · 3 pts

**As an** indie developer,
**I want** my semantic utility classes (success, info, warning, danger) to automatically harmonise with my primary brand colour,
**so that** the framework feels visually cohesive without manual colour-picking.

**Acceptance Criteria:**
- AC1: The SCSS engine automatically applies `color.mix()` to blend the user's Primary hex into the four semantic defaults.
- AC2: The resulting hex colours are calculated safely without breaking compilation.
- AC3: The resulting tinted colours maintain passing WCAG 2.1 AA text contrast.

**Dependencies:** None
**Status:** ⚪ To Do

---

### UC-012 · CSS Layer (`@layer`) Support · 🟦 Nice to Have / Roadmap · 3 pts

**As an** indie developer integrating nanoCSS into a legacy app,
**I want** the framework's output to be wrapped in a specific CSS `@layer nanocss;`,
**so that** I don't suffer specificity wars against my existing legacy stylesheets.

**Acceptance Criteria:**
- AC1: The Configuration Form provides an advanced toggle: "Wrap in CSS `@layer`".
- AC2: The final output groups all rules into scoped layers (`@layer prefix.reset, prefix.components`, etc.).
- AC3: The `.zip` export and downloaded CSS properly wrap the files.

**Dependencies:** None
**Status:** ⚪ To Do

---

## Sprint 4 — UI Fixes, NanoCSS Integration & Refinement

> **Sprint Goal:** Address all newly discovered snags, UI/UX issues, and complete the self-hosting nanoCSS transition.
> **Estimated Capacity:** 20 story points

---

### UC-013 · Corporate Preset Default & Live Preview Migration · 🟥 Must Have · 3 pts

**As an** indie developer,
**I want** the "Corporate" preset to be the default and the live preview positioned on the config page,
**so that** the app landing page focuses on a Hero Banner and configuration happens in context.

**Acceptance Criteria:**
- AC1: Use "Corporate" preset as the default configuration form values.
- AC2: Remove Live Preview block from Landing page, use it on Config page.
- AC3: First element on the Landing page must be a Hero Banner.

---

### UC-015 · Complete NanoCSS Self-Hosting (Remove Custom Chrome) · 🟥 Must Have · 5 pts

**As an** indie developer,
**I want** the app to use its own generated nanoCSS framework for all interface styling,
**so that** we rely purely on our framework without custom chrome or inline styles.

**Acceptance Criteria:**
- AC1: Remove all inline styles from the app.
- AC2: Use the compiled `nanocss.css` from `app/assets/stylesheets/nanocss-compiled/`.
- AC3: Use nanoCSS components for the app interface (no custom ones).
- AC4: Allow minimal tweaks in `application.css/scss` *only after* importing/compiling nanoCSS.
- AC5: Separate config page styling from Live Preview styling using the `@layer` directive.

---

### UC-016 · Quick Update Stylesheet Reload · 🟧 Should Have · 3 pts

**As an** indie developer,
**I want** the QuickUpdate function to change/reload the site's stylesheet file,
**so that** it doesn't just replace the contents of an inline `<style>` tag.

**Acceptance Criteria:**
- AC1: Clicking QuickUpdate updates a `<link rel="stylesheet">` or dynamically replaces it rather than editing a `<style>` block.

---

### UC-017 · Fix Live Preview Contrast Bug · 🟥 Must Have · 2 pts

**As a** user,
**I want** the text in the live preview to remain visible,
**so that** changing a config variable doesn't make text blend into the background.

**Acceptance Criteria:**
- AC1: Fix the issue where text changes to background colour when config is updated.
- AC2: Remove or adjust the hardcoded overrides in App-level Tokens inside the `:root` selector of `application.css`.

---

### UC-018 · Fix Copy/Share Link · 🟥 Must Have · 2 pts

**As a** user,
**I want** the copy/share link to correctly encode and decode theme settings,
**so that** I can share my themes reliably.

**Acceptance Criteria:**
- AC1: Fix the copy/share link feature so that it works as originally intended.

---

### UC-019 · Component Catalogue Enhancements & Responsive Test Page · 🟧 Should Have · 5 pts

**As an** indie developer,
**I want** a consistent, responsive component catalogue and a dedicated test page,
**so that** I can verify all components in a natural layout.

**Acceptance Criteria:**
- AC1: Fix visual nightmare on component catalogue (text/bg contrast, navbar spanning issue, consistent header/footer).
- AC2: Ensure all nanoCSS components are responsive.
- AC3: Create a test page with all components in their natural place with dummy copy (Lorem Ipsum) and image placeholders.

---

### UC-020 · Dynamic Font Rendering in Google Fonts API · 🟦 Nice to Have · 3 pts

**As a** user,
**I want** each font name in the selection list to display in its own font style,
**so that** I can preview the font visually before selecting it.

**Acceptance Criteria:**
- AC1: Wrap each font name in a span or custom component and dynamically apply its own `font-family` style in the dropdown/list.

---

## Icebox _(Unscheduled / Future)_

_(Empty)_