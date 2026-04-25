# Changelog

> **Project:** nanoCSS
> All notable changes to this project are documented here.
> Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
> Versioning follows [Semantic Versioning](https://semver.org/): `MAJOR.MINOR.PATCH`
>
> - **MAJOR** — Breaking change (incompatible API change)
> - **MINOR** — New feature, backwards-compatible
> - **PATCH** — Bug fix, backwards-compatible

---

## [Unreleased]

> _Changes merged to main but not yet in a numbered release.
> Move entries to a versioned section at release time._

### Added
- _(empty — Sprint 6 has not yet started.)_

### Changed
- _(empty)_

### Fixed
- _(empty)_

---

## [0.5.0] — 2026-04-25 — Sprint 5

### Added
- UC-021: Default nanoCSS Icon Set — 20 inline SVG icons exposed via `NanoIconHelper#nano_icon(:name)`. Inherits `currentColor`; auto-sized to surrounding `font-size`.
- UC-022: Floating Theme Switcher component — `<prefix>-theme-switcher` fixed bottom-right, semantic `<details>/<summary>` toggle, persists Light/Dark + active preset to `localStorage`.
- New "Icons" section in the Component Catalogue.

### Changed
- Component count grows 17 → 20 (Card variants from Sprint 2 + Theme Switcher + Icon Set this sprint).
- PRD bumped to v0.4 — retrofit pass to canonise shipped reality (link-swap preview, 4 font slots, Corporate-as-default, thin PWA shell).

---

## [0.4.0] — 2026-04-11 — Sprint 4

### Added
- UC-013: Hero Banner as the first element of the landing page; live preview moved off the landing page onto `/themes/configure`.
- UC-016: New `GET /themes/css?theme=…&preview=true` endpoint serves scoped, layered CSS for the link-swap preview mechanism.
- UC-019 (partial): `/components/test` page renders every component in a natural layout with dummy copy and image placeholders.
- UC-020: Each font name in the Google Fonts dropdown renders in its own typeface for visual preview.

### Changed
- **BREAKING (preview mechanism):** `POST /themes/preview` now responds with a Turbo Stream that replaces the `<link rel="stylesheet" id="nanocss-preview-link">` tag's `href`, instead of replacing the contents of an inline `<style>` tag. See ADR-003.
- **BREAKING (defaults):** Form-load defaults are now the Corporate preset (`#1e40af / #6366f1 / #06b6d4`). The original PRD §9.1 palette (`#3b82f6 / #8b5cf6 / #ec4899`) survives as the *Playful* preset. See ADR-004.
- `application.css` — removed hardcoded App-level Token overrides inside `:root` that were causing UC-017 contrast bug.
- `ThemeConfiguration#from_base64` now silently falls back to default config on decode error (UC-018 AC2).

### Fixed
- UC-017: Live-preview text no longer changes to background colour when the user updates a config variable.
- UC-018: Copy/Share Link round-trip — encoding now includes `font_code`, `excluded_components`, `wrap_in_layer`; decoding fully restores them.

### Known Issues (deferred)
- UC-015 carried forward — chrome still uses bespoke `.top-nav`/`.glass-panel` and 81 inline `style=` attributes remain. Split into UC-034/UC-035/UC-036 for Sprint 8.
- UC-019 carried partial — visual nightmare on the catalogue largely fixed but the responsive sweep is deferred to UC-033 (Sprint 7).

---

## [0.3.0] — 2026-03-28 — Sprint 3

### Added
- UC-014: Google Fonts API integration — `GoogleFontsService` fetches and caches the catalogue for 24 h. Stimulus-powered search dropdowns for Heading, Subtitle, Body, and **Code** font slots.
- UC-010: Per-Component Toggle Selection — UI checkboxes for every component; deselected components are stripped from generated CSS and the SCSS ZIP.
- UC-011: Automated Semantic Colour Tinting — `success/info/warning/danger` utilities now blend against the user's primary via `color.mix()`.
- UC-012: CSS `@layer` Support — advanced toggle wraps output in `@layer prefix.config, prefix.components`. ZIP exports apply the layering.
- New `font_code` slot on `ThemeConfiguration` and matching `--{prefix}-font-code` CSS custom property.

### Security
- UC-014 AC3: Strict whitelist validation against the cached Google Fonts catalogue before any `font_*` value is interpolated into `@import url(...)`. Defends against CSS / open-redirect injection.

### Known Issues (deferred)
- UC-010 AC2 — the per-component opt-out uses brittle regex strips against the monolithic `_components.scss`. Modular replacement queued for UC-032 (Sprint 7).
- UC-011 AC3 — formal WCAG 2.1 AA contrast audit deferred to UC-045 (Sprint 10).

---

## [0.2.0] — 2026-03-14 — Sprint 2

### Added
- UC-005: Component Catalogue page (`/components`) renders the full 17-component set with copy-to-clipboard snippets that respect the active prefix.
- UC-006: Colour Harmony Generator — Complementary / Analogous / Triadic suggestions surfaced as swatch buttons in the configurator.
- UC-007 (Card Variants): Four Card layouts shipped — Basic, Image-First, Profile, Stat. (Retrofitted into the backlog at Sprint 5 close — was tracked only in PRD.)
- `ColourHarmonyService` PORO with HSL rotation algorithms.

### Known Issues (deferred)
- UC-005 — visual quality issues on the catalogue (contrast, navbar spanning) carried forward to UC-019 / UC-033.
- UC-006 — Monochromatic and Split-Complementary harmonies (FR-006 specifies 5) deferred to UC-038 (Sprint 9).

---

## [0.1.0] — 2026-02-28 — Sprint 1

### Added
- UC-001: Three preset cards (Corporate, Playful, Minimalist) on the landing page with live preview via Hotwire Turbo Streams.
- UC-002: Configuration form with Basic / Advanced mode toggle, colour pickers, font selectors, anchor sliders, 5-part Drop Shadow and Text Shadow matrices.
- UC-003: ZIP download of `nanocss.css`, `nanocss.min.css`, and `scss/` source via `ZipAssemblerService` (rubyzip).
- UC-004: Shareable theme URLs via base64-encoded `?theme=` query parameter (initial implementation; round-trip bug fixed in UC-018).
- `ThemeConfiguration` PORO (`ActiveModel::Model`) — colour, prefix, font, anchor, shadow, tier, mode attributes; regex validators for hex and prefix.
- `ScssCompilerService` orchestrates in-memory Dart Sass compilation via the `sass` Ruby gem (`Sass.compile_string`).
- 17-component framework hand-authored as monolithic `app/assets/stylesheets/nanocss/_components.scss` (Card variants added in Sprint 2).
- Thin PWA shell — `manifest.json` + minimal service worker — for installability and icon presentation only. (Reverses the original PRD §3 PWA rejection — see ADR-002.)

### Security
- Server-side regex validation for hex codes (`/\A#[0-9a-fA-F]{6}\z/`) and prefix (`/\A[a-z][a-z0-9-]*[a-z0-9]\z/`).
- _Known gap:_ validators are defined on `ThemeConfiguration` but not yet invoked by `ThemesController` before compilation. Tracked as UC-023 (Sprint 6).

### Known Issues (deferred)
- UC-002 AC3 — server-side rejection of invalid hex/prefix not wired up; falls through to Sass. Tracked as UC-023.
- UC-003 AC2 — `nanocss.min.css` produced by `gsub(/\s+/, ' ')`, which is incorrect. Real minification queued for UC-040 (Sprint 9).

---

## Change Type Reference

| Type | Use When |
|---|---|
| **Added** | New feature, endpoint, component, or Use Case |
| **Changed** | Existing feature works differently — behaviour or API changed |
| **Deprecated** | Feature still works but will be removed in a future version |
| **Removed** | Feature or endpoint has been deleted |
| **Fixed** | Bug or incorrect behaviour corrected |
| **Security** | Vulnerability patched, dependency updated for security, auth change |
