---
vc-id: cdac6d97-eb76-44c8-888a-985bc9bd83f2
---
# Product Requirements Document (PRD)

> **Project:** nanoCSS — CSS Theme & Component Generator
> **Version:** 0.4
> **Author:** [Your Name]
> **Date:** 2026-04-25
> **Status:** 🟢 Canonised — reflects shipped Sprint 1–5 reality

> **v0.4 retrofit note:** This revision absorbs every feature that was actually shipped during Sprints 1–5 into the canonical spec (Card Variants, Icon Set, Theme Switcher, `font_code` slot, `<link>`-swap preview, scoped preview layer, `/themes/css` endpoint, test page, PWA scaffolding). Items that were specified but **not yet implemented** are still listed but are explicitly cross-referenced to the new Sprint 6+ Use Cases that will deliver them. No previously implemented behaviour has been removed.

---

## 1. Executive Summary

Independent developers building web projects are caught in a no-man's land: heavyweight utility frameworks like Tailwind impose an opinionated HTML class-soup, while bare-bones resets offer nothing at all. **nanoCSS** solves this by giving the solo developer a browser-based generator that produces a genuinely lightweight, bespoke CSS framework — styled exactly to their brand, containing only the components they actually need, and downloaded as a ready-to-use file in seconds.

The companion web app lets a user pick a preset theme or dial in their own colours, fonts, and spacing, watch their choices render live against real HTML primitives, then download their tailored framework as standard CSS, minified CSS, or a full modular SCSS archive. Because the output is pure, dependency-free CSS and Vanilla JS, it drops straight into any project — static site, Rails app, or React build — with no lock-in and no build-tool ceremony.

The product name carries a promise: the user controls the **nano** footprint by selecting only the layers they need, from bare semantic HTML styling right up to the full suite of interactive components.

---

## 2. Assumptions & Dependencies

### Assumptions

- [ ] Target users are developers comfortable with HTML/CSS; no GUI drag-and-drop builder is required for MVP.
- [ ] Users will access the app via a modern browser (Chrome 110+, Firefox 110+, Safari 16+, Edge 110+).
- [ ] No user accounts, authentication, or persistent server-side storage are required for MVP; the app is fully stateless.
- [ ] Browser `localStorage` is available for persisting the user's dark-mode preference on the client side.
- [ ] Google Fonts API is publicly accessible without an API key for listing and embedding fonts (standard `@import` URL pattern).
- [ ] Dart Sass can be executed in-process (no shell subprocess) within the Rails/Passenger environment — specifically, the `sass-embedded` or `sass` gem must be compatible with the VPS Ruby version and glibc.
- [ ] The downloaded `.zip` file is assembled and streamed entirely in memory — no temporary files written to disk.
- [ ] An 8px / 0.5rem baseline spacing grid and the Major Third (1.25) typographic scale are acceptable defaults and are aesthetically defensible choices for the preset themes.
- [ ] "Indie dev" persona: single developer, solo project, comfortable copy-pasting HTML snippets from documentation.

### External Dependencies

| Dependency | Type | Owner / Provider | Notes |
|---|---|---|---|
| Ruby on Rails 7+ | App framework | OSS / Shopify | Stateless config; no ActiveRecord |
| Hotwire (Turbo + Stimulus) | Frontend reactivity | OSS / 37signals | Turbo Streams for live preview; Stimulus for any minimal app-UI JS |
| Dart Sass (`sass` gem) | SCSS compiler | Google / OSS | In-memory compilation via `Sass.compile_string()` |
| Google Fonts API | Font catalogue | Google | Dynamic `@import` URL injection; no API key required for web embeds |
| Rubyzip (or equivalent) | ZIP assembly | OSS | Streaming `.zip` archive to browser on download |

---

## 3. Out of Scope (MVP)

> These items are explicitly deferred. Stating them here is the primary defence against scope creep.

- [ ] User accounts, authentication, or server-side saved theme persistence.
- [ ] Database or any server-side persistence of theme configurations.
- [ ] A native mobile app (web only).
- [ ] Social / OAuth login.
- [ ] Multi-language / i18n support (English only, v1).
- [ ] A visual drag-and-drop page builder.
- [ ] WYSIWYG component editor (copy-paste HTML snippets only).
- [ ] A CDN-hosted distribution of nanoCSS (download only for MVP).
- [ ] WordPress, Shopify, or other CMS plugin integrations.
- [ ] A CLI tool / npm package (post-MVP roadmap item).
- [ ] Paid plans, SaaS billing, or a freemium gate.
- [ ] Component-level theming overrides (global design tokens only for MVP).

> **v0.4 update — PWA scope reversal:** A minimal PWA shell (manifest + service-worker) was scaffolded during Sprint 4 to satisfy `allow_browser versions: :modern` and to provide an installable name/icon. It does **not** attempt offline compilation. PWA is therefore **in scope as a thin install/icon shell only**; offline Dart Sass compilation remains explicitly rejected (see §6 note). Supersedes the v0.2 PWA rejection.

---

## 4. Functional Requirements

### FR-001: Preset Theme Selection
**Description:** The Landing Page must offer at minimum three ready-made preset themes (e.g., Corporate, Playful, Minimalist). Clicking a preset immediately applies it to the live preview — no form submission required. Each preset encodes a complete set of design tokens (colours, fonts, spacing multipliers).
**Priority:** 🟥 Must Have

### FR-002: Custom Theme Configuration
**Description:** The Configuration Page must expose a sidebar form allowing the user to override any design token. At minimum: Primary, Secondary, and Tertiary brand colours (hex input + colour picker); **four** font selections — Heading, Subtitle, Body, **and Code** (Google Fonts); baseline font size; baseline spacing unit; border-radius variants (sm, md, lg, pill); and the CSS/SCSS variable namespace prefix (default: `nanocss`).

> **v0.4 — Code font slot canonised.** The Code font slot was added in Sprint 1 (UC-002 AC7) and emits `$nanocss-font-code` / `--{prefix}-font-code`. PRD §9.4 lists four font slots accordingly.
**Priority:** 🟥 Must Have

### FR-003: Basic / Advanced Configuration Modes
**Description:** The sidebar form must operate in two modes. **Basic Mode** exposes only the anchor variables (brand colours, base font size, base spacing unit). **Advanced Mode** unlocks individual token overrides, allowing the user to break the ratio system and set, for example, `$nanocss-space-4` to an arbitrary value independently. Switching between modes must not reset previously entered values. Only explicitly clicking a dedicated **Reset** button will restore all inputs to their defaults.
**Priority:** 🟥 Must Have

### FR-004: Real-Time Live Preview
**Description:** Any change to a configuration input must trigger an immediate, seamless preview update — no full page reload. The Turbo Stream must swap a `<link rel="stylesheet" href="/themes/css?theme=…&preview=true">` element inside `#nanocss-preview-style`; the browser fetches the freshly compiled CSS and applies it to the preview canvas. A short opacity cross-fade (managed by the `preview` Stimulus controller) hides flash-of-unstyled-content during the swap. The perceived latency from input change to visual update must be under 200ms on a standard broadband connection. The preview must render against real, representative HTML elements: headings, body text, buttons (primary/secondary/danger), form inputs, a card, and a badge.

> **v0.4 — Reload mechanism canonised.** Previous PRD revisions described a `<style>` innerHTML replacement. UC-016 (Sprint 4) intentionally replaced this with a `<link>` swap pointing at the new `GET /themes/css` endpoint so the browser's stylesheet cache key changes per-config. The `<style>` injection is still used by the layout's *global* `#nanocss-framework-style` block for app-chrome dogfooding. See §11.6.

**Priority:** 🟥 Must Have

### FR-005: Selective Component Inclusion
**Description:** The user must be able to choose which layers of the framework to include in their download. The selector must offer at minimum three distinct tiers:
1. **Nano** — CSS reset + semantic HTML element styling only (no class-based components).
2. **Standard** — Nano + helper utility classes (spacing, flex/grid, typography, visibility).
3. **Full** — Standard + the complete interactive component library.

Individual component-level toggling (e.g., include Carousel but exclude Modal) is a **Should Have** for Sprint 1 and a **Must Have** by v1.0.
**Priority (tier selector):** 🟥 Must Have | **Priority (per-component toggle):** 🟧 Should Have

### FR-006: Colour Harmony Generator
**Description:** When the user selects a Primary brand colour, the app must offer an automatic palette suggestion using harmony algorithms. Sprint 2 shipped **Complementary, Analogous, and Triadic**. **Monochromatic and Split-Complementary** remain on the roadmap and are scheduled in Sprint 9 (UC-037). Suggested palettes must be presented as clickable swatches that populate the Secondary and Tertiary colour inputs. The user may accept, modify, or ignore the suggestion.
**Priority:** 🟧 Should Have (3 of 5 shipped — see UC-037)

### FR-007: Semantic Colour Tinting
**Description:** The SCSS compiler must apply `color.mix()` to blend a subtle proportion of the user's Primary colour into each of the four semantic colours (Success, Info, Warning, Danger), preserving their conventional hue identity while achieving visual cohesion with the brand palette. This must happen automatically during compilation; no additional user input is required.
**Priority:** 🟧 Should Have

### FR-008: Google Fonts Integration
**Description:** The font selector inputs must dynamically fetch the available font list from the Google Fonts API and present them in a searchable/filterable dropdown. Selecting a font must inject the correct `@import url(...)` directive into the generated SCSS output. Three distinct font slots must be available: Headers, Subtitles, Body Text.
**Priority:** 🟧 Should Have

### FR-009: Dark Mode (Three-Tier System)
**Description:** The generated framework CSS must support dark mode via a strict three-tier priority cascade:
1. OS-level: `@media (prefers-color-scheme: dark)` as the baseline default.  *(Pending — UC-031, Sprint 7.)*
2. User override: `<html data-theme="dark|light">` attribute toggled by a Vanilla JS snippet (included in the download). *(Shipped Sprint 5 — UC-022.)*
3. Persistence: User override stored in browser `localStorage` and reapplied on page load. *(Shipped Sprint 5 — UC-022.)*

The nanoCSS generator app itself must also implement this same three-tier system for its own UI.

> **v0.4 — Tier 1 deferred.** The data-theme override and localStorage persistence shipped in Sprint 5 via the Floating Theme Switcher. The OS-level `prefers-color-scheme` baseline is captured as UC-031 in Sprint 7. The framework partial currently emits a `[data-theme="dark"]` block; a `@media (prefers-color-scheme: dark) { … }` block must be added without removing the existing override block.

**Priority:** 🟥 Must Have

### FR-010: Download / Export Engine
**Description:** A "Download" button (persistent, accessible from the Configuration and Component Catalogue pages) must compile the current configuration in-memory using Dart Sass and stream a `.zip` archive to the browser. The archive must contain:
- `nanocss.css` — full human-readable compiled CSS.
- `nanocss.min.css` — minified CSS.
- `scss/` — the modular raw SCSS source files (variables, mixins, reset, utilities, and one file per component).

The archive name and the CSS variable prefix must reflect any custom namespace the user has configured (e.g., `mytheme.css` if prefix is `mytheme`).
**Priority:** 🟥 Must Have

### FR-011: Component Catalogue
**Description:** A dedicated page must display every framework component with: (a) a live rendered example, (b) copyable raw HTML snippet, and (c) where applicable, a copyable Vanilla JS snippet. Components must render using the currently active theme configuration. Every top-level HTML element of a component must carry a namespaced class reflecting the active prefix (e.g. `.nanocss-card`, `.nanocss-modal`) to ensure unambiguous style targeting and zero collision with host-page CSS.

A **sidebar navigation** allowing jumping directly to any component is a v0.4 follow-up — scheduled as UC-038 (Sprint 9). The current single-scroll catalogue is acceptable for MVP.

A separate **Responsive Test Page** (`GET /components/test`, shipped UC-019, Sprint 4) renders every component in a natural composed layout (nav → hero → cards → forms → footer) for end-to-end responsive verification.

> **v0.4 — Namespacing exceptions to fix.** Two components currently violate the prefix rule: Breadcrumbs (`nav[aria-label="breadcrumb"]`) and Tooltip (`[data-tooltip]`). UC-030 (Sprint 7) brings them into compliance.

**Priority:** 🟥 Must Have

### FR-012: Variable Namespacing
**Description:** The user must be able to set a custom string prefix for all generated SCSS variables (`$<prefix>-*`) and CSS custom properties (`--<prefix>-*`). The default prefix is `nanocss`. The prefix input must be validated: lowercase alphanumeric and hyphens only, no spaces, no leading/trailing hyphens. This prevents naming collisions when the generated CSS is loaded alongside other stylesheets.
**Priority:** 🟥 Must Have

### FR-013: CSS Reset (Bespoke)
**Description:** The framework must include a bespoke, lightweight modern CSS reset baked directly into the output — not a third-party file (no Normalize.css, no Eric Meyer reset). The reset must be scoped to the user's chosen prefix where applicable and must not conflict with host-page styles.
**Priority:** 🟥 Must Have

### FR-014: Shareable Theme URLs
**Description:** The Configuration Page must provide a "Copy Share Link" button that encodes the entire current theme configuration (all design token values, selected tier, namespace prefix) as a base64 URL parameter appended to the configuration page URL (e.g., `/configure?theme=eyJwcmltYXJ5IjoiI...`). When a user visits such a URL, the configuration form must be pre-populated from the decoded parameter — no database or user account required. The encoded payload must be URL-safe base64 (standard `Base64.urlsafe_encode64` in Ruby). A malformed or tampered parameter must fail gracefully, loading the default configuration with an inline notice.
**Priority:** 🟥 Must Have (Sprint 1)

### FR-015: Card Variants
**Description:** The Card component must ship with four colour variants — `.{prefix}-card`, `.{prefix}-card-primary`, `.{prefix}-card-secondary`, `.{prefix}-card-tertiary`, `.{prefix}-card-neutral`. Each variant tints the card's `<header>` block with the corresponding brand or neutral colour. The base `.{prefix}-card` is the unbranded default.
**Priority:** 🟧 Should Have (shipped Sprint 2)

### FR-016: Icon Set
**Description:** The framework must ship a curated set of ~20 lightweight inline-SVG icons (menu, close, chevrons, check, alert, info, search, user, home, settings, star, heart, download, copy, link, external-link, moon, sun). Icons use `stroke="currentColor"` so they recolour with surrounding text. A Rails helper `nano_icon(name, size:)` renders the SVG. An "Icons" panel exists in the Component Catalogue.
**Priority:** 🟧 Should Have (shipped Sprint 5)

### FR-017: Floating Theme Switcher Component
**Description:** The framework must ship a `.{prefix}-theme-switcher` component — a fixed-position widget pinned to bottom-right, built on `<details>`/`<summary>` so it expands without JS. The widget exposes (a) a Dark Mode toggle that flips `data-theme` on `<html>` and persists to `localStorage`, and (b) preset buttons that link to `/configure?theme=<base64>` to apply a starter theme. The switcher renders inside the generator app's own layout and is also available as a downloadable component.
**Priority:** 🟧 Should Have (shipped Sprint 5)

### FR-018: Stylesheet Reload Endpoint
**Description:** A `GET /themes/css` route must return a `text/css` body for the supplied configuration (via `?theme=<base64>` *or* form params, plus `?preview=true` to scope output to `#preview-canvas`). This endpoint is the target of the Turbo-Stream `<link>` swap described in FR-004 and is the ZIP-less path for applying a configuration to any nanoCSS-aware page.
**Priority:** 🟥 Must Have (shipped Sprint 4 alongside UC-016)

### FR-019: Responsive Test Page
**Description:** A `GET /components/test` route must render every framework component composed into a single natural layout — nav, hero, content cards, forms, lists, pagination, footer — using Lorem-Ipsum copy and image placeholders. Its purpose is end-to-end responsive verification; it intentionally has no copy buttons or sidebar.
**Priority:** 🟧 Should Have (shipped Sprint 4 — UC-019 AC3)

---

## 5. User Flows

### Flow 1: First-Time User — Preset to Download

1. User arrives at the **Landing Page**; sees the value proposition headline and three preset theme cards (Corporate, Playful, Minimalist).
2. User clicks **"Playful"** — the preview pane on the landing page instantly applies the Playful theme tokens.
3. User clicks **"Customise"** — navigated to the **Configuration Page** with the Playful preset pre-loaded.
4. User changes the Primary colour via the hex input; the colour harmony generator suggests Secondary and Tertiary swatches.
5. User accepts a suggested palette; the live preview pane updates seamlessly via Turbo Stream.
6. User switches to **Advanced Mode** and overrides `border-radius-pill` to `4px`.
7. User selects the **Standard** tier from the layer selector.
8. User clicks **"Download"** — receives `nanocss.zip` containing `nanocss.css`, `nanocss.min.css`, and the `scss/` folder.

**Edge Cases:**
- If Dart Sass compilation fails (e.g., invalid hex entered), the preview must display an inline error notice and the Download button must be disabled until the error is resolved.
- If Google Fonts API is unreachable, font selectors fall back to the system font stack defaults (`variables.scss` defaults apply).

---

### Flow 2: Returning Developer — Component Reference

1. User arrives directly at the **Component Catalogue** page (bookmarked URL).
2. User clicks **"Modal"** in the sidebar navigation.
3. The Modal component section scrolls into view, showing: a live demo trigger button, the raw HTML snippet, and the Vanilla JS snippet.
4. User clicks the copy icon next to the HTML snippet — the snippet is copied to clipboard; a brief "Copied!" toast confirms.
5. User pastes into their project and it works out-of-the-box with any nanoCSS build.

**Edge Cases:**
- If the user has no active theme configured (direct navigation), the catalogue must render using the default nanoCSS tokens from `variables.scss`.

---

### Flow 3: User Configures Custom Namespace

1. User on the Configuration Page opens **Advanced Mode**.
2. User locates the **Namespace Prefix** input and changes `nanocss` to `mytheme`.
3. Live preview immediately reflects `--mytheme-*` variable names in the generated `<style>` block (visible via browser DevTools).
4. On download, the archive is named `mytheme.zip` and all internal files use the `mytheme` prefix.

**Edge Cases:**
- If the user inputs an invalid prefix (spaces, uppercase, leading hyphens), an inline validation message appears and the Download button is disabled.

---

## 6. Non-Functional Requirements

| Category | Requirement | Target |
|---|---|---|
| Performance | Turbo Stream preview update (input → repaint) | < 200ms perceived latency |
| Performance | Download `.zip` generation & stream start | < 2 seconds |
| Performance | Initial page load (Landing Page) | < 2 seconds on 4G |
| Accessibility | Standard | WCAG 2.1 AA |
| Accessibility | All interactive elements | Visible `:focus` state required |
| Accessibility | Keyboard navigation | Full keyboard operability for all components |
| Browser Support | Minimum targets | Chrome 110+, Firefox 110+, Safari 16+, Edge 110+ |
| Output Quality | Generated CSS validity | Must pass W3C CSS Validator with zero errors |
| Output Quality | Generated CSS — fluid typography | All font sizes must use `clamp()` for viewport-responsive scaling |
| Output Quality | Generated CSS — units | `rem` throughout; no `px` in typography or spacing outputs |
| Output Quality | Zero JS dependencies (exported framework) | No jQuery, Alpine, Stimulus, or any external library in the download |
| Uptime | Availability target | 99.5% |
| Internationalisation | Languages | English only (v1) |
| SEO | Landing Page | Semantic HTML, meaningful `<title>` and `<meta description>` |

> **Note — PWA explicitly rejected:** A Progressive Web App (installable, offline-capable) is not feasible for nanoCSS. The core value proposition — real-time Dart Sass compilation and ZIP generation — is entirely server-side. An offline shell would be non-functional. PWA is out of scope for all versions.

---

## 7. Technical Constraints & Environment

### Constraints (Non-Negotiable)

- **Language / Runtime:** Ruby 3.x / Rails 7.2.3 (Stateless MVP — no ActiveRecord, no database).
- **Frontend Reactivity:** Hotwire (Turbo Drive, Turbo Streams, Stimulus) — no React, Vue, or other SPA framework for the generator app UI.
- **SCSS Compiler:** Dart Sass only (`sass` gem, `Sass.compile_string()` in-process). No LibSass (deprecated). No Node-based Sass.
- **Exported Framework JS:** Strictly Vanilla JS. Zero external dependencies in the download artefact. No Stimulus dependency for end-users.
- **Exported Framework CSS:** Pure CSS / SCSS. No Tailwind utility classes, no Pico CSS, no Bootstrap, no jQuery.
- **Variable naming:** All SCSS variables and CSS Custom Properties must be strictly lowercase. No camelCase, no PascalCase.
- **Spacing system:** 8px / 0.5rem baseline grid (`$nanocss-space-*` scale as defined in `variables.scss`).
- **Typography scale:** Major Third (ratio 1.25) from `text-xs` (0.800rem) to `text-xxl` (2.441rem) as defined in `variables.scss`.

### Preferences (Flexible)

- **Hosting:** Self-hosted VPS — **IONOS, Linux AlmaLinux (RHEL-based), Apache + Phusion Passenger**. Deployment is via `git pull` + Passenger restart, or Capistrano. Dart Sass must run as an in-process Ruby gem (`Sass.compile_string()`) — no Node.js process, no shell subprocesses. Apache must proxy Passenger and serve static assets directly from `public/`. Package management is `dnf` (not `apt`); verify `sass-embedded` binary compatibility against the AlmaLinux glibc version before committing to it.
- **Deployment:** Capistrano recommended for zero-downtime deploys. At minimum, a documented `git pull && bundle install && passenger-config restart-app` runbook is required.
- **Testing:** RSpec (unit/integration) + Capybara + Selenium (system tests — Selenium required for JS-driven component behaviours such as Modal `.showModal()`). Minitest acceptable.
- **CI/CD:** GitHub Actions (run tests on push; no auto-deploy to VPS for MVP — manual deploy acceptable).
- **Asset Pipeline:** Propshaft or Sprockets (standard Rails 7 choice).
- **ZIP Library:** Rubyzip preferred.

### Team Context

- **Team Size:** 1 (solo indie developer).
- **Key Skills:** Ruby on Rails, SCSS/CSS, Vanilla JS, basic Hotwire.
- **Known Gaps:** Potentially limited DevOps/server-admin experience — keep Apache VirtualHost and Passenger configuration as simple as possible; document the setup in the project README. No DBA — zero-database architecture is the correct call.

### Token Architecture & Multiplier Logic

All spacing, sizing, and structural tokens are mathematically derived from standard base anchor variables. This ensures the output CSS maintains a rigid, predictable design system while allowing the user granular control in Advanced Mode.

**The Anchor Variables (Defaults)**

- `$nanocss-base-typography`: `1rem` (16px)
    
- `$nanocss-base-space`: `0.5rem` (8px — drives padding and gaps)
    
- `$nanocss-base-margin`: `1.25rem` (20px)
    
- `$nanocss-base-radius`: `0.25rem` (4px)
    
- `$nanocss-base-border-width`: `2px`
    

**The Standard Multiplier Scale** Utility classes and component geometry scale from the anchors using a fixed mathematical map:

- `-xs`: `0.25x` base
    
- `-sm`: `0.5x` base
    
- `-md`: `1x` base (The default if no suffix is applied)
    
- `-lg`: `1.5x` base
    
- `-xl`: `2x` base
    
- `-xxl`: `3x` base
    

**Shadow Architecture** Shadows are defined by explicit matrices rather than simple multipliers to preserve aesthetic quality.

- **Text Shadow Base:** `0.25rem (X) | 0.25rem (Y) | 0.5rem (Blur) | Neutral 700 | 0.5 (Opacity)`
    
- **Drop Shadow Base:** `0.5rem (X) | 0.5rem (Y) | 1rem (Blur) | Neutral 900 | 0.25 (Opacity) | inset: false`

---

## 8. Security & Compliance

### Authentication & Authorisation

- No user authentication required for MVP (stateless, no accounts).
- No session management required.

### Input Sanitisation (Critical)

The primary attack surface is the SCSS compiler: a malicious user could attempt to inject arbitrary SCSS/CSS or attempt path traversal via the configuration form. Mitigations:

- **Colour inputs:** Server-side validation against a strict hex colour regex (`/\A#[0-9a-fA-F]{6}\z/`) before any value is passed to the compiler. Reject anything that does not match.
- **Namespace prefix input:** Server-side validation against `/\A[a-z][a-z0-9-]*[a-z0-9]\z/` (lowercase alphanumeric and internal hyphens only). Maximum length: 32 characters.
- **Font name inputs:** Whitelist against the Google Fonts API catalogue — never interpolate raw user strings directly into `@import` URLs. Validate the font name exists in the fetched catalogue before use.
- **All SCSS compilation:** Performed with `Sass.compile_string()` using only the in-memory string — no user-supplied file paths, no filesystem access from user input.

### Known Threat Vectors

- **SCSS injection:** User inputs values that break out of the variable assignment and inject arbitrary SCSS rules. Mitigated by strict input validation before any value reaches the compiler.
- **Path traversal:** User attempts to reference external SCSS files via font or prefix inputs. Mitigated by whitelisting and regex validation.
- **Denial of Service via compilation:** Pathological SCSS inputs causing long compile times. Mitigated by input length limits and a server-side compilation timeout.
- **XSS via Turbo Stream:** Compiled CSS injected into the DOM via a `<style>` tag. Ensure the Turbo Stream template HTML-escapes the CSS payload before injection; the browser will treat it as CSS text, not executable script.

### Data Classification

| Data Type | Sensitivity | Storage | Notes |
|---|---|---|---|
| Theme configuration (colours, fonts, spacing) | Low | Client-side only (form state) | Never persisted server-side in MVP |
| Dark mode preference | Low | Browser `localStorage` | User's own device only |
| Generated CSS output | None | In-memory, streamed | Discarded after download stream completes |

### Compliance

- [ ] GDPR: No personal data collected in MVP → minimal compliance burden. If server logs record IPs, a basic privacy notice is required.
- [ ] Cookie consent banner: Not required if no tracking cookies are set. Confirm before launch.
- [ ] Google Fonts: Standard Google Fonts embed via `@import` in generated CSS will cause end-user browsers to make requests to Google's CDN. Document this in the framework's README so downstream users are informed.

---

## 9. The Design System (nanoCSS Framework Specification)

### 9.1 Colour Architecture — 8-Tier System

| Tier | Variables | Notes |
|---|---|---|
| Brand — Primary | `--{prefix}-primary` | User-configurable hex. Default: `#3b82f6` |
| Brand — Secondary | `--{prefix}-secondary` | User-configurable. Default: `#8b5cf6`. Harmony-suggested. |
| Brand — Tertiary | `--{prefix}-tertiary` | User-configurable. Default: `#ec4899`. Harmony-suggested. |
| Neutrals | `--{prefix}-neutral-100` … `neutral-900` | 5-stop greyscale (100, 300, 500, 700, 900). Odd stops sufficient for MVP. |
| Semantic — Success | `--{prefix}-success` | Green hue, Primary-tinted via `color.mix()`. Default: `#10b981`. |
| Semantic — Info | `--{prefix}-info` | Blue hue, Primary-tinted. Default: `#0ea5e9`. |
| Semantic — Warning | `--{prefix}-warning` | Yellow hue, Primary-tinted. Default: `#f59e0b`. |
| Semantic — Danger | `--{prefix}-danger` | Red hue, Primary-tinted. Default: `#ef4444`. |

### 9.2 Elevation (Shadow) Scale

Three levels defined in `variables.scss`: `shadow-sm`, `shadow-md`, `shadow-lg`. Shadow opacity must respect dark mode (increase opacity in dark contexts).

### 9.3 Z-Index Scale

Four reserved levels: `dropdown` (1000), `sticky` (1020), `modal` (1040), `toast` (1060). These must be used consistently across components.

### 9.4 Typography

- **Scale:** Major Third (×1.25): `text-xs` (0.800rem) → `text-sm` → `text-md` → `text-lg` → `text-xl` → `text-xxl` (2.441rem).
- **Fluid sizing:** Each step wrapped in `clamp()` for viewport-responsive scaling.  *(Mixin defined in `_mixins.scss`; full adoption pending — see UC-029, Sprint 7.)*
- **Font slots:** **Four** independent selections — Headings, Subtitles, Body, **Code**. Each maps to a Google Fonts `@import`. *(Code slot canonised v0.4.)*
- **Weights:** light (300), normal (400), medium (500), bold (700).
- **Line height base:** 1.5 (`$nanocss-line-height`).

### 9.5 Spacing Grid

8px / 0.5rem baseline. Six steps: `space-1` (0.25rem / 4px) through `space-6` (3rem / 48px). Used for all margin, padding, and gap values.

### 9.6 Breakpoints (Mobile-First)

| Variable | Value | Context |
|---|---|---|
| `bp-sm` | 576px | Large phones / small tablets |
| `bp-md` | 768px | Tablets |
| `bp-lg` | 992px | Laptops |
| `bp-xl` | 1200px | Desktops |

---

## 10. Component Library Specification

### Interactivity Philosophy

> Zero-JS first. If HTML5/CSS3 can do it natively, use it. Vanilla JS is permitted only where native HTML is genuinely insufficient.

| # | Component | HTML Strategy | Interaction Logic | JS Required? |
|---|---|---|---|---|
| 0 | Text Banner | `<hgroup><h1><p>` | Flex/Grid layout | ❌ |
| 1 | Hero Banner | `<section>` + Text Banner | `min-height: Xvh`, responsive | ❌ |
| 2 | Carousel | `display: flex` container | `scroll-snap-type: x mandatory` | ❌ |
| 3 | Accordion | `<details>` + `<summary>` | Native browser toggle | ❌ |
| 4 | Card | `<article>` | Flexbox header/body/footer | ❌ |
| 5 | Dropdown | `<details>` or `:focus-within` | CSS-driven visibility | ❌ |
| 6 | Group | Layout wrapper | Negative margin / flex join | ❌ |
| 7 | Loading | `<span>` or SVG | CSS `@keyframes` | ❌ |
| 8 | Modal | `<dialog>` | `.showModal()` / `.close()` + `::backdrop` | ✅ Minimal |
| 9 | Nav / NavBar | `<nav>` | Responsive toggle (checkbox hack or 5-line JS) | ✅ Optional |
| 10 | Progress | `<progress>` | Global native element styling | ❌ |
| 11 | Tooltip | `[data-tooltip]` attribute | `::before` / `::after` on `:hover` | ❌ |
| 12 | Buttons | `<button>` / `.btn` | Hover darken, active scale via CSS | ❌ |
| 13 | Badges | `<span>` | Inline-block, border-radius variable | ❌ |
| 14 | Tags | `<span>` + close `<button>` | Close action | ✅ Minimal |
| 15 | Breadcrumbs | `<nav><ol>` | CSS `::after` separators | ❌ |
| 16 | Pagination | `<nav>` | Flexbox button group | ❌ |
| 17 | Tabs | `<input type="radio">` + `<label>` + `<div>` panels | CSS `:checked` + `:has()` sibling selector — zero JS | ❌ |
| 18 | Card Variants | `.card-primary` / `-secondary` / `-tertiary` / `-neutral` modifiers on `<article>` | Header tint via brand variables | ❌ |
| 19 | Theme Switcher | `<details>` floating widget | `data-theme` flip + `localStorage` persist | ✅ Minimal |
| 20 | Icon Set | Inline SVG, `currentColor` stroke | Rendered via `nano_icon` helper | ❌ |

> **Note on Tabs:** `component_spec.md` lists Tabs as a component with Vanilla JS logic but it is absent from `master_feature_specification.md`'s numbered list. **Tabs is included** — this is a documentation gap in the master spec, not an intentional omission.

> **v0.4 — components 18, 19, 20 canonised.** Card Variants (Sprint 2), Theme Switcher (UC-022, Sprint 5), and the Icon Set (UC-021, Sprint 5) are now part of the official component library. The 17-component count from previous PRD revisions becomes a 20-component count.

### Standard HTML Element Styling (Nano Tier)

- **Forms:** `<input>`, `<textarea>`, `<select>`, `<label>`, `<fieldset>` styled globally out-of-the-box. Search bar variant helper included.
- **Tables:** Global default styling. `.table-striped` helper class included.
- **Typography:** All heading levels (`h1`–`h6`), `<p>`, `<blockquote>`, `<code>`, `<pre>`, `<kbd>`, `<abbr>`.
- **Links:** Styled with `:hover` and `:visited` states.

### Helper / Utility Classes (Standard Tier — Highly Constrained)

| Category | Examples |
|---|---|
| Spacing | `.m-1` … `.m-6`, `.mt-*`, `.mb-*`, `.mx-*`, `.my-*`, `.p-*`, `.pt-*`, `.gap-*` |
| Flexbox | `.flex`, `.flex-col`, `.flex-wrap`, `.items-center`, `.justify-between` |
| Grid | `.grid`, `.grid-cols-2`, `.grid-cols-3`, `.grid-cols-4` |
| Typography | `.text-center`, `.text-right`, `.font-bold`, `.font-light`, `.text-sm`, `.text-lg` |
| Display / Visibility | `.hidden`, `.block`, `.inline-block`, `.sr-only` |

---

## 11. System Architecture

### 11.1 Application Architecture Overview

```mermaid
graph TD
    A[User Browser] -->|HTTP / Turbo Drive| B(Rails Router)
    B --> C[ThemesController]
    C -->|index| D[Landing Page View]
    C -->|preview via Turbo| E[ThemeConfiguration PORO]
    E --> F[ScssCompilerService]
    F -->|Sass.compile_string| G[Dart Sass In-Memory]
    G -->|CSS String| F
    F -->|CSS String| H[Turbo Stream Template]
    H -->|Replace style tag| A
    C -->|download| I[ZipAssemblerService]
    I --> J[In-Memory ZIP Archive]
    J -->|Stream| A
    K[Google Fonts API] -->|Font catalogue JSON| L[FontsController / Stimulus]
    L -->|Populates font dropdown| A
```

### 11.2 Controller Layer

| Controller | Action | Responsibility |
|---|---|---|
| `ApplicationController` | `before_action :compile_default_nanocss` | Compiles the per-request default-theme CSS into `@nanocss_css` so the layout can dogfood the framework on every page |
| `ThemesController` | `index` | Renders Landing Page (Hero + 3 preset cards). Quick-Apply on a card POSTs to `/themes/preview` |
| `ThemesController` | `show` | Renders Configuration Page with sidebar form + preview canvas. Pre-populates from `?theme=<base64>` if present |
| `ThemesController` | `preview` | Accepts Turbo form POST; renders `preview.turbo_stream.erb` which swaps the preview `<link>`, the harmony swatches, and the share button |
| `ThemesController` | `download` | Compiles final CSS/SCSS; calls `ZipAssemblerService`; streams `.zip` (or single `.css` when `download_format=css`) |
| `ThemesController` | `css` | **(v0.4)** Returns `text/css` body for any configuration; consumed by the preview `<link>` swap and by external embeds |
| `ComponentsController` | `index` | Renders Component Catalogue page |
| `ComponentsController` | `test_page` | **(v0.4)** Renders the Responsive Test Page composing every component into a natural layout (FR-019) |
| `FontsController` | `index` | Proxies/caches Google Fonts API catalogue; returns JSON for the `fonts` Stimulus controller's dropdown |

### 11.3 Model Layer (POROs — No Database)

**`ThemeConfiguration`** *(canonical attribute names — v0.4)*
- Includes: `ActiveModel::Model`, `ActiveModel::Validations`
- Attributes: `primary`, `secondary`, `tertiary`, `prefix`, `font_heading`, `font_subtitle`, `font_body`, `font_code`, `base_typography`, `base_space`, `base_margin`, `base_radius`, `base_border_width`, `text_shadow`, `drop_shadow`, `tier` (nano/standard/full), `mode` (basic/advanced), `margin_md`, `space_md`, `excluded_components` (Array), `wrap_in_layer` (Boolean)
- Key Methods:
  - `to_scss_variables_string()` — formats all attributes into valid SCSS variable declarations. Always emits `$prefix: '<prefix>'` for class/CSS-property naming and `$nanocss-*` overrides so they collide with the `!default` declarations in `_variables.scss`.
  - `to_base64()` — serialises only attributes that differ from defaults; URL-safe Base64.
  - `self.from_base64(string)` — decodes; falls back to a `new` (default) configuration on any decode error.
  - `as_json()` — serialiser used by `to_base64`.
- Validations: hex format on all colour fields; safe-string regex on prefix; presence on required fields; **Google Fonts whitelist** on every font slot (rejects unknown names against `GoogleFontsService.catalogue`); **excluded_components** must be an array of known component slugs.

> **v0.4 — Validator enforcement gap.** The validators above are correctly defined but not currently invoked on the request path before SCSS compilation. UC-023 (Sprint 6) wires `valid?` into `ThemesController#preview` and `#download`.

### 11.4 Service Layer

**`ScssCompilerService`**
- Interface: `.call(theme_configuration, tier: nil, scope: nil)`
- Responsibilities:
  1. Reads base nanoCSS SCSS partials from `/app/assets/stylesheets/nanocss/` filesystem (read-only).
  2. Prepends the dynamically generated variable declarations from `ThemeConfiguration#to_scss_variables_string()`.
  3. Injects FR-007 semantic-tint blocks (`color.mix(success, primary, 90%)`) when a Primary is set.
  4. Conditionally includes component partials based on selected tier.
  5. Honours `scope:` — when set (e.g. `'#preview-canvas'`), the `:root` selector in `_custom-properties.scss` is rewritten to the scope so preview-only token changes do not bleed into the global app chrome. The whole scoped output is wrapped in `@layer config { … }`.
  6. Honours `wrap_in_layer` (UC-012) — when true, output is wrapped in `@layer <prefix> { … }`.
  7. Prepends `@import url(https://fonts.googleapis.com/css2?…)` for each unique configured font.
  8. Executes `Sass.compile_string()` (Dart Sass in-memory).
  9. Returns `{ css: String, error: String | nil }` — never raises; caller handles error state.

**`ZipAssemblerService`**
- Interface: `.call(theme_configuration, tier:)`
- Responsibilities:
  1. Calls `ScssCompilerService` for the full CSS string.
  2. Minifies the CSS string.
  3. Assembles a Rubyzip in-memory `OutputStream` with the directory structure: `{prefix}.css`, `{prefix}.min.css`, `scss/variables.scss`, `scss/mixins.scss`, `scss/reset.scss`, `scss/utilities.scss`, `scss/components/*.scss`.
  4. Returns the raw ZIP binary for streaming.

**`ColourHarmonyService`**
- Interface: `.call(primary_hex, harmony_type:)`
- Responsibilities: Calculates Secondary/Tertiary colour suggestions using HSL rotation. Currently supports `:complementary`, `:analogous`, `:triadic`. `:monochromatic` and `:split_complementary` are scheduled in UC-037.

**`GoogleFontsService`** *(canonised v0.4)*
- Interface: `.catalogue` (returns `Array<String>` of font family names; cached for 24 hours)
- Responsibilities: Fetches the Google Fonts metadata JSON; falls back to a small whitelist (`Inter`, `Roboto`, `Oswald`, `Fira Code`, `Source Code Pro`, `JetBrains Mono`, `Merriweather`) when the API is unreachable.

**`NanoIconHelper`** *(canonised v0.4)*
- Interface: `nano_icon(name, size: 24, class: '')`
- Responsibilities: Renders an inline SVG from the curated 21-icon library with `stroke="currentColor"` so icons inherit text colour. Logs a warning and renders an empty SVG for unknown names.

### 11.5 SCSS File Structure (Output Archive)

**Current shipped layout (v0.4 — monolithic components):**

```
{prefix}.zip
├── {prefix}.css
├── {prefix}.min.css
└── scss/
    ├── _variables.scss
    ├── _mixins.scss
    ├── _custom-properties.scss
    ├── _reset.scss
    ├── _base.scss
    ├── _components.scss        (single file — all 20 components)
    └── _utilities.scss         (Standard + Full tiers only)
```

**Target layout (UC-032, Sprint 7) — modular components:**

```
{prefix}.zip
├── {prefix}.css
├── {prefix}.min.css
└── scss/
    ├── _variables.scss
    ├── _mixins.scss
    ├── _custom-properties.scss
    ├── _reset.scss
    ├── _base.scss
    ├── _utilities.scss         (Standard + Full tiers only)
    └── components/
        ├── _buttons.scss
        ├── _badges.scss
        ├── _tags.scss
        ├── _loading.scss
        ├── _progress.scss
        ├── _tooltip.scss
        ├── _hero-banner.scss
        ├── _carousel.scss
        ├── _accordion.scss
        ├── _card.scss
        ├── _card-variants.scss
        ├── _dropdown.scss
        ├── _group.scss
        ├── _modal.scss
        ├── _nav.scss
        ├── _breadcrumbs.scss
        ├── _pagination.scss
        ├── _tabs.scss
        ├── _theme-switcher.scss
        └── _icons.scss
```

Until UC-032 lands, per-component exclusion (FR-005, UC-010) is implemented by regex-stripping numbered comment sections out of the monolithic `_components.scss`. This is functionally correct but brittle; UC-032 supersedes it.

### 11.6 Real-Time Preview Data Flow (v0.4 — link-swap)

```mermaid
sequenceDiagram
    participant U as User Browser
    participant TC as ThemesController
    participant TConf as ThemeConfiguration
    participant TS as Turbo Stream
    participant CSS as ThemesController#css
    participant SC as ScssCompilerService

    U->>TC: Form input change (Turbo POST /themes/preview)
    TC->>TConf: Instantiate with form params
    TC->>TS: Render preview.turbo_stream.erb
    TS-->>U: Replace #nanocss-preview-style with new <link href="/themes/css?theme=…&preview=true">
    U->>U: preview Stimulus controller fades canvas to opacity 0
    U->>CSS: GET /themes/css?theme=…&preview=true
    CSS->>SC: .call(config, scope: '#preview-canvas')
    SC-->>CSS: { css: "@layer config { … }", error: nil }
    CSS-->>U: text/css body
    U->>U: <link> load fires; preview controller fades back to opacity 1
```

**Why a link, not an inline `<style>`?** A `<link>`'s `href` is the cache key. When the configuration changes, the URL changes, the browser fetches fresh CSS, and the swap is atomic — the old stylesheet is removed *after* the new one is parsed, eliminating the flash-of-unstyled-content the inline-`<style>` approach exhibited. The app-chrome dogfooded CSS still uses an inline `<style id="nanocss-framework-style">` because it does not change per-request.

### 11.7 Dark Mode Architecture (Three-Tier)

```mermaid
graph TD
    A[Page Load] --> B{localStorage has data-theme?}
    B -->|Yes| C[Apply stored value to html data-theme]
    B -->|No| D{OS prefers-color-scheme: dark?}
    D -->|Yes| E[Browser applies dark CSS via media query]
    D -->|No| F[Light mode default applied]
    C --> G[Theme active]
    E --> G
    F --> G
    H[User clicks dark/light toggle] --> I[Vanilla JS sets html data-theme]
    I --> J[Save to localStorage]
    J --> G
```

---

## 12. Success Metrics (Definition of Done)

### Technical Definition of Done

- [ ] All Use Case Acceptance Criteria (Backlog Sprint 1) pass.
- [ ] `ThemeConfiguration` model validations reject all invalid hex codes and disallowed prefix strings.
- [ ] `ScssCompilerService` returns a valid CSS string for all three preset themes and all three tier selections.
- [ ] Turbo Stream preview update round-trip measured at < 200ms on localhost (serves as baseline proxy for production performance).
- [ ] Generated CSS passes W3C CSS Validator with zero errors for all three preset themes at all three tiers.
- [ ] All 17 components render correctly in Chrome 110+, Firefox 110+, Safari 16+, and Edge 110+.
- [ ] Download `.zip` extracts correctly and the contained CSS correctly styles a bare vanilla HTML test page.
- [ ] WCAG 2.1 AA accessibility audit passes on the generator app itself.
- [ ] All interactive component HTML snippets (Modal, Nav toggle, Tags) are keyboard-operable and have visible focus states. Tabs are CSS-only (radio button / `:has()` pattern) and require no JS operability testing.
- [ ] No critical or high-severity linting errors (RuboCop, ESLint/Stylelint if applicable).
- [ ] Shareable theme URL: a base64-encoded URL round-trips correctly — encoding a theme configuration and decoding it from the URL parameter must reproduce an identical `ThemeConfiguration` object with zero data loss.
- [ ] A malformed or tampered `?theme=` parameter loads the default configuration without raising an unhandled exception.
- [ ] Security: all colour and prefix inputs fail closed (reject-by-default) against validation regexes.

### Product / Business Definition of Done

- [ ] A solo developer can arrive at the Landing Page, choose a preset, tweak their brand colour, select the Standard tier, and download a working CSS file — all within 3 minutes, without reading any documentation.
- [ ] The downloaded CSS, when linked in a bare `<html>` page with no other styles, produces a visually coherent, professional-looking result using only semantic HTML elements.
- [ ] A developer can find the Modal component in the catalogue, copy the HTML snippet, paste it into their project, and have a functioning modal in under 60 seconds.
- [ ] The generated framework has zero external runtime dependencies (confirmed by absence of any `<script src="">` or `@import` referencing a non-Google-Fonts external URL in the CSS output).

---

## 13. Open Questions & Conflicts Resolved

> This section documents discrepancies found across source documents and the resolution taken.

| # | Conflict / Gap | Source Documents | Resolution |
|---|---|---|---|
| 1 | **Tabs component** present in `component_spec.md` but absent from `master_feature_specification.md` numbered component list. | component_spec.md vs master_feature_specification.md | **Tabs is included.** Gap in master spec, not intentional omission. Implementation updated to CSS-only (radio button + `:has()`) per owner preference for zero-JS. |
| 2 | **Neutral colour scale** — `variables.scss` defines 5 stops (100, 300, 500, 700, 900); `master_feature_specification.md` describes "100 to 900 scale" implying 9 stops. | variables.scss vs master_feature_specification.md | **5-stop scale confirmed by owner.** Brand colour expression is handled by the Primary/Secondary/Tertiary trio; neutrals need only enough range for text, borders, and backgrounds. |
| 3 | **Font variables** — `variables.scss` defines `font-sans`, `font-serif`, `font-mono`; `master_feature_specification.md` describes "Headers, Subtitles, Body Text" slots. | variables.scss vs master_feature_specification.md | **Use the Headers/Subtitles/Body model** for the generator UI. SCSS output retains `font-sans/serif/mono` as fallback stack variables; Google Font selections overlay these. |
| 4 | **`ColourHarmonyService`** described in `master_feature_specification.md` but not represented in either system design document. | master_feature_specification.md vs system_design docs | **Added as a named Service Object** in §11.4. |
| 5 | **Per-component toggle** not defined in detail but implied by the "Nano footprint" brand promise. | User clarification + master_feature_specification.md | **Tier selector (Nano/Standard/Full) is Must Have for MVP; per-component toggle is Should Have for Sprint 1, Must Have by v1.0.** See FR-005. |
| 6 | **`ZipAssemblerService`** implied by export requirements but not named or designed in existing system design docs. | PRD.md, master_feature_specification.md | **Added as a named Service Object** in §11.4. |
| 7 | **Hosting** — previous docs assumed managed PaaS (Heroku/Fly.io). | System design docs vs owner clarification | **Self-hosted VPS, Apache + Phusion Passenger.** Dart Sass must run as an in-process gem. Deployment via Capistrano or manual runbook. See §7 Technical Constraints. |
| 8 | **Shareable Theme URLs** — originally deferred to post-MVP roadmap. | PRD v0.1 Roadmap vs owner clarification | **Promoted to Sprint 1 Must Have (FR-014).** Implemented as base64 URL parameter — zero database dependency. |
| 9 | **PWA compliance** — added to NFR table by owner in v0.1 edit. | User edit vs architectural reality | **v0.2 rejected → v0.4 partially reinstated.** A thin PWA shell (`manifest.json.erb`, `service-worker.js`) shipped in Sprint 4 to provide installable name/icon. Offline Sass compilation remains rejected. |
| 10 | **Code (`font_code`) font slot** — added in Sprint 1 (UC-002 AC7), absent from PRD §9.4. | Implementation vs PRD v0.3 §9.4 | **Canonised v0.4.** PRD §9.4 now states four slots: Heading, Subtitle, Body, Code. |
| 11 | **Preview reload mechanism** — PRD v0.3 §11.6 specified `<style>` innerHTML replacement; UC-016 (Sprint 4) shipped a `<link>` swap to `/themes/css`. | PRD v0.3 §11.6 vs UC-016 | **Canonised v0.4.** §11.6 rewritten to describe the link-swap flow. The inline `<style>` mechanism remains for the static app-chrome compile only. |
| 12 | **Default brand colours** — PRD §9.1 lists `#3b82f6 / #8b5cf6 / #ec4899`; current `ThemeConfiguration` defaults are `#1e40af / #6366f1 / #06b6d4` (the Corporate preset). | PRD §9.1 vs `ThemeConfiguration` | **UC-025 (Sprint 6).** Restore framework defaults to the §9.1 values; Corporate preset remains a *form starter* but is not used as the global fallback. |
| 13 | **17-component table** vs the 20 components actually shipped (Card Variants, Icons, Theme Switcher). | PRD v0.3 §10 vs `_components.scss` | **Canonised v0.4.** §10 expanded to 20 entries; FR-015/16/17 added. |
| 14 | **Component class namespacing** — Breadcrumbs and Tooltip use unprefixed root selectors. | Implementation vs FR-011 | **UC-030 (Sprint 7).** Add `.{prefix}-breadcrumb` and `.{prefix}-tooltip` wrappers without breaking the existing global selectors. |
| 15 | **Validators defined but unenforced** on the request path. | PRD §8 vs `ThemesController` | **UC-023 (Sprint 6).** Wire `valid?` into `#preview` and `#download`. |
| 16 | **Modular SCSS in export ZIP** — PRD §11.5 specified one file per component; current ZIP ships a monolithic `_components.scss`. | PRD §11.5 vs `ZipAssemblerService` | **UC-032 (Sprint 7).** Split components into a `components/` subfolder. |

---

## 14. Suggested Improvements & Post-MVP Roadmap

> Items beyond the MVP scope but worth capturing now to avoid architectural decisions that would make them hard to add later.

- **CDN Distribution:** Host the default nanoCSS build on jsDelivr or unpkg for `<link>` embed without download.
- **CLI / npm Package:** `npx nanocss init` for project scaffolding — natural post-MVP evolution.
- **Per-Component Toggle (v1.0):** Granular include/exclude per component in the export.
- **Community Preset Gallery:** User-submitted themes stored as static JSON — no database required if hosted as flat files.
- **CSS Layers (`@layer`) Support:** Ship the framework output using CSS cascade layers for zero-specificity-conflict integration in host projects.
- **Container Query Variants:** As browser support matures, offer container-query based responsive helpers as an opt-in add-on tier.

---

## Revision History

| Version | Date | Author | Summary of Changes |
|---|---|---|---|
| 0.1 | 2026-04-11 | Big Kahuna (Claude) | Initial draft — synthesised from 8 source documents + user clarification |
| 0.2 | 2026-04-11 | Big Kahuna (Claude) | Tabs → CSS-only (radio/:has() pattern); neutral scale confirmed at 5 stops; shareable URLs promoted to Sprint 1 FR-014; hosting updated to VPS/Apache/Phusion Passenger; conflicts table expanded to 8 entries |
| 0.3 | 2026-04-11 | Big Kahuna (Claude) | Merged owner's v0.1 edits: FR-003 reset button clarification; FR-011 namespaced component classes; Rails pinned to 7.2.3; hosting updated to IONOS/AlmaLinux with Selenium added to test stack; grid-cols-4 added; PWA requirement rejected with rationale (conflict #9); Known Gaps cleaned up |
| 0.4 | 2026-04-25 | Big Kahuna (Claude) | **Canonisation pass.** Retrofits the spec to match what was actually built in Sprints 1–5. Adds FR-015 Card Variants, FR-016 Icon Set, FR-017 Theme Switcher, FR-018 `/themes/css` endpoint, FR-019 Responsive Test Page. Adds 4th `font_code` slot to §9.4. Rewrites §11.6 preview flow to the `<link>`-swap mechanism. Reinstates a thin PWA shell (no offline compile). Expands component count 17 → 20. Adds conflicts #10–#16 with explicit Sprint 6+ Use Case mappings for each remaining gap. **No previously implemented feature has been removed.** |
