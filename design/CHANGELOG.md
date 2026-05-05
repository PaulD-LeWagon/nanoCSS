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

---

## [0.8.0] — 2026-05-05 — Sprint 8

### Fixed
- UC-047: `theme_controller.js` now always sets `data-theme` explicitly — `removeAttribute` replaced with `setAttribute("data-theme", "light")` so OS media query is never re-engaged on a dark machine.
- UC-048: Catalogue and preview pages force `data-theme="light"` on the body — prevents `@media (prefers-color-scheme: dark)` from inverting component renders on dark-OS machines.
- UC-049: Hero `color: #fff` scoped to direct `h1/h2/h3/p` children only — nested components inside `.{prefix}-hero` no longer inherit white text.
- UC-050: Live-preview body font now emitted correctly (canvas-scoped `font-family` in `ScssCompilerService`); breadcrumb conflict with host nav resolved via scoped selector ordering.

### Changed
- UC-034: All 81 inline `style=` attributes removed from `app/views/`; replacements use nanoCSS utility classes. `spec/lint/inline_styles_spec.rb` fails CI if new inline styles are introduced.
- UC-036: App chrome replaced — `.top-nav` swapped for `nanocss-nav`; `.glass-panel`/`.nav-links` custom CSS blocks removed; `application.css` reduced to layout shims only.
- UC-037: Floating Theme Switcher mounted in `application.html.erb`; suppressed on `/themes/configure` to avoid colliding with the config form.

### Added
- UC-035: Quick Apply on the landing page now replaces both the preview stylesheet (`#nanocss-preview-link`) and the chrome stylesheet (`#nanocss-framework-style`) — preset colour changes are immediately visible in the navbar, hero, and buttons.

### Sprint Metrics
- Planned: 24 pts · Delivered: 24 pts · Velocity: 24
- 145 specs, 0 failures · 0 RuboCop offences · 0 Brakeman warnings

---

## [0.7.0] — 2026-05-04 — Sprint 7

### Added
- UC-028: Stimulus `dropdown_controller.js` — dropdowns inside navbars stay open during item clicks; Esc + outside-click close; multi-dropdown isolation.
- UC-029: Stimulus `navbar_controller.js` — mobile hamburger toggle with Esc-close and `aria-expanded` tracking. Responsive chrome media query eliminates horizontal overflow at 320 px.
- UC-030: Prefixed breadcrumb (`.{prefix}-breadcrumb`) and tooltip (`.{prefix}-tooltip`) CSS selectors; backward-compat `nav[aria-label]` and `[data-tooltip]` aliases retained.
- UC-031: Three-tier dark mode — Tier 1 `@media (prefers-color-scheme: dark) { :root { … } }`, Tier 2a `[data-theme="dark"]`, Tier 2b `[data-theme="light"]`. Tier 3 (localStorage) was already shipped.
- UC-032: `_components.scss` split into 18 individual partials under `nanocss/components/`. `ScssCompilerService` replaced brittle regex-strip with `COMPONENT_ALIASES` include-list. `ZipAssemblerService` auto-exports the modular tree.
- UC-033: Responsiveness spec suite — 320 / 768 / 1280 / 1920 px × no-overflow + key-component assertions. PNG artefacts saved to `tmp/breakpoint_*.png`.
- UC-046: Obsidian glass-morphism preset — `surface_blur`, `surface_opacity`, `border_glow_alpha` tokens added to `ThemeConfiguration`; Obsidian entry in `config/presets.yml`; 4th preset card auto-renders on landing page. Hero uses `primary → secondary` CSS-var gradient. Card + nav gain `backdrop-filter` consuming `surface-blur`.

### Changed
- Hero component now uses a `linear-gradient(primary, secondary)` background instead of a flat neutral colour.
- Card component headers now carry `font-size: var(--{prefix}-text-md)` from the typography scale.
- Quick Apply preset button now passes all preset YAML attributes to `ThemeConfiguration` (not just primary/secondary/tertiary).

### Known Issues
All four regressions (UC-047–UC-050) fixed in Sprint 8 (v0.8.0).

---

## [0.6.0] — 2026-05-03 — Sprint 6

### Added
- UC-024: Strict 32-char prefix length validator (`validates :prefix, length: { maximum: 32 }`).
- UC-023: Validation gate in `ThemesController#preview` and `#download` — invalid params rejected before `ScssCompilerService` is invoked. Preview returns 200 with an error Turbo Stream; download returns 422.
- UC-025: Preset definitions externalised to `config/presets.yml` — adding a new preset now requires editing only that file, no controller change.
- UC-027: Harmony swatch buttons rewritten with Stimulus `harmony_controller.js` — eliminates the only inline `onclick` ERB interpolation in the codebase (XSS surface removed).
- `harmony_controller.js` registered in the Stimulus manifest.
- `<div id="validation-errors">` in the configure form; `preview.turbo_stream.erb` populates it on invalid submit.

### Changed
- Sprint cadence updated: AI-assisted pace is 2–3 sprints per day; story point scale recalibrated to hours (1 pt ≈ 10–20 min, 5 pt ≈ 2–3 hr).
- `ThemeConfiguration#initialize` now strips blank entries from `excluded_components` (sentinel `[""]` sent by the hidden field no longer fails validation).
- `DEFINITION-OF-DONE.md` updated with mandatory before/after screenshot gate and UI-preservation rule.
- `CLAUDE.md` updated with `[CRITICAL]` hard do-not for unauthorised UI removal.

### Fixed
- UC-026: Four specs repaired to match shipped reality (Corporate defaults, `<link>` swap instead of `<style>` tag).
- System specs for colour harmony and theme customisation now stub `GoogleFontsService.catalogue` to avoid live API calls on every Turbo Stream submit.
- `excluded_components: [""]` sentinel from the hidden field no longer causes a validation error on every preview request.

### Security
- UC-027: Removed the only inline `onclick="…'<%= hex %>'…"` ERB→JS interpolation — XSS surface eliminated. Harmony swatch values now flow through Stimulus `data-` attributes.

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
