---
vc-id: 2508316c-9bcc-46ae-8e90-fcc4f10c3de1
---
# System Design (nanoCSS)

> **Project:** nanoCSS
> **Last Updated:** 2026-04-25 (Sprint 5 close — retrofit to shipped reality)
> **Document Version:** v0.4
>
> _This document was retrofitted at the end of Sprint 5 to canonise the
> architecture as it actually shipped. Where the original Sprint 1 design
> drifted, the new shape is described here and the drift is recorded in
> `ARCHITECTURE_DECISIONS.md`._

---

## 1. High-Level Architecture

**Architectural style:** Modular Monolith (Ruby on Rails 7.2.3) + thin PWA shell.
**Rationale:** The application is entirely stateless. Rails combined with Hotwire (Turbo Streams + Stimulus) provides the fastest path to a reactive UI without the overhead of a separate SPA frontend. Compilation is handled in-memory using Dart Sass via the `sass` Ruby gem. A minimal PWA manifest + service worker ships the install/icon shell only — there is no offline runtime (see ADR-002).

```mermaid
graph TD
    Browser[Browser]

    subgraph Rails[Rails 7.2.3 — Modular Monolith]
      AC[ApplicationController<br/>before_action: compile_default_nanocss]
      TC[ThemesController]
      CC[ComponentsController]
      TC -->|index/show| TCFG[ThemeConfiguration PORO]
      TC -->|preview/css/download| SCSS[ScssCompilerService]
      TCFG --> SCSS
      SCSS -->|Sass.compile_string| Sass[(sass gem<br/>Dart Sass)]
      Sass --> SCSS
      TC -->|harmony swatches| CHS[ColourHarmonyService]
      TC -->|font catalogue| GFS[GoogleFontsService]
      TC -->|download| ZIP[ZipAssemblerService]
      AC -->|chrome CSS| SCSS
    end

    Browser -->|GET /| TC
    Browser -->|POST /themes/preview| TC
    Browser -->|GET /themes/css?theme=...&preview=true| TC
    Browser -->|POST /themes/download| TC
    Browser -->|GET /components| CC
    Browser -->|GET /components/test| CC

    TC -->|turbo_stream:<br/>swap link[href]| Browser
    TC -->|text/css| Browser
    TC -->|application/zip| Browser

    Browser -.->|manifest.json + sw.js| PWA[(thin install shell)]
```

**Preview flow (link-swap, not style-tag injection — see ADR-003):**

```mermaid
sequenceDiagram
    participant U as User
    participant F as Form (Stimulus)
    participant TC as ThemesController
    participant CSS as /themes/css
    participant B as Browser

    U->>F: change input (e.g. primary colour)
    F->>TC: POST /themes/preview (FormData, Turbo Stream)
    TC->>TC: encode config → base64 token
    TC-->>F: turbo_stream replace #nanocss-preview-link<br/>with <link href="/themes/css?theme={token}&preview=true">
    F->>B: DOM swap; browser fetches new href
    B->>CSS: GET /themes/css?theme={token}&preview=true
    CSS->>CSS: ThemeConfiguration.from_base64(token)
    CSS->>CSS: ScssCompilerService.call(cfg, scope: "#nanocss-preview")
    CSS-->>B: text/css (scoped + @layer config)
    B-->>U: paint
```

The link-swap mechanism is what makes the **Quick Apply** preset buttons on the landing page work — clicking a preset POSTs the preset values, the link `href` flips, and the browser-cached CSS is replaced. See **UC-035** (Sprint 8) for why this currently does not visually re-skin the *app chrome* itself: most of what the user sees is custom overrides, not nanoCSS classes.

---

## 2. Cross-Cutting Concerns

### 2.1 State Management (Stateless Architecture)
- **Approach:** Zero database. The source of truth for a user's configuration is the DOM form state.
- **Persistence:** Shareable URLs use `Base64.urlsafe_encode64` to pack the `ThemeConfiguration` attributes as JSON into the `?theme=` query parameter. `ThemeConfiguration.from_base64(token)` reverses this; if decoding fails, the method falls back silently to a default-config instance.
- **Dark Mode:** Three-tier cascade — system `prefers-color-scheme` → explicit `data-theme="dark|light"` on `<html>` (set by the floating Theme Switcher, UC-022) → `localStorage` for persistence across reloads.

### 2.2 Error Handling Strategy
- **Compiler Errors:** If a user inputs a combination that breaks Sass compilation (e.g., severe ratio disruption), `ScssCompilerService` rescues `Sass::CompileError`, logs the failure, and returns `{ css: nil, error: "..." }`. The controller renders a `text/plain` 422 for the `/themes/css` endpoint and a flash for HTML actions.
- **Input Validation:** `ThemeConfiguration` defines `ActiveModel::Validations` regex validators for hex codes (`/\A#[0-9a-fA-F]{6}\z/`) and prefix names. **Known gap (UC-023, Sprint 6):** the controller does not yet call `valid?` before invoking the compiler. Invalid values currently fall through to Sass, which may either accept them or raise — see ADR-005.
- **Font Whitelist:** `GoogleFontsService.valid?(name)` is called by `ThemeConfiguration` before any `font_*` value is interpolated into an `@import url(...)` rule, defending against CSS injection (FR-008).

### 2.3 Deployment & Environment
- **Hosting:** Self-hosted on an AlmaLinux 9 VPS (IONOS S Package).
- **Web Server:** Apache acting as a reverse proxy to Phusion Passenger.
- **Editor Ops:** System operations and file edits on the server to be handled using Vim. Development primarily driven via the Antigravity IDE.
- **Capistrano runbook:** outstanding — see UC-040 (Sprint 10).

### 2.4 Testing Strategy
- **Unit:** RSpec for POROs and Services (`ThemeConfiguration`, `ScssCompilerService`, `ZipAssemblerService`, `ColourHarmonyService`, `GoogleFontsService`).
- **System:** Capybara + Selenium for end-to-end Hotwire interaction and JS-driven UI behaviour (e.g., modal dialogues, harmony swatches).
- **Current state (Sprint 5 close):** 77 of 81 specs green. The 4 failing specs are tracked in UC-026 (Sprint 6) — three of them assert pre-Sprint-4 default values (`#3b82f6` etc.) that were superseded when Corporate became the default; the fourth asserts the `<style>`-tag preview that was superseded by the link-swap mechanism (ADR-003).

---

## 3. Database Schema

**None.** This application is explicitly stateless to reduce operational overhead and liability. All configurations are handled in-memory and via URL parameters. No database engine is provisioned. The `database.yml` references a SQLite file but no migrations exist and no model inherits from `ActiveRecord::Base`.

---

## 4. Internal API Contracts (Hotwire Routes)

### `GET /` (root) → `ThemesController#index`
Renders the landing page (Hero + Quick Apply preset cards + Test Page CTA).
The page includes `<link id="nanocss-preview-link" rel="stylesheet" href="/themes/css?theme={default_token}">` so the preset cards can flip it without a full reload.

### `GET /themes/configure` → `ThemesController#show`
Renders the configuration form (sidebar) plus a live preview pane scoped to `#nanocss-preview`.

### `POST /themes/preview` → `ThemesController#preview`
**Request:** `FormData` submitted via Turbo Stream containing `ThemeConfiguration` attributes plus optional `harmony` selection.
**Response (Turbo Stream, multi-target):**
```html
<turbo-stream action="replace" target="nanocss-preview-link">
  <template>
    <link id="nanocss-preview-link"
          rel="stylesheet"
          href="/themes/css?theme={base64_token}&preview=true">
  </template>
</turbo-stream>
<turbo-stream action="replace" target="harmony-options">
  <template><!-- _harmony_options.html.erb --></template>
</turbo-stream>
<turbo-stream action="replace" target="share-link">
  <template><!-- updated copy-link with new token --></template>
</turbo-stream>
```

### `GET /themes/css` → `ThemesController#css`
**Query params:**
- `theme` — base64 URL-safe token (optional; falls back to default config)
- `preview=true` — wraps output in `@layer config` and scopes to `#nanocss-preview` (set by `ScssCompilerService` `scope:` argument)
- `tier=core|standard|full` — controls which component partials to include

**Response:** `Content-Type: text/css; charset=utf-8` with `Cache-Control: public, max-age=300` for non-preview requests, `no-store` for preview requests.

### `POST /themes/download` → `ThemesController#download`
**Request:** `FormData` containing the final `ThemeConfiguration`.
**Response:** `Content-Type: application/zip`, `Content-Disposition: attachment; filename="nanocss.zip"`. Streams the assembled archive directly. The archive contains:
```
nanocss/
├── nanocss.css            # un-minified, layered
├── nanocss.min.css        # currently a whitespace-collapsed string (UC-039)
├── README.md              # placeholder
└── scss/
    ├── _variables.scss    # user's overrides as $-vars
    ├── _mixins.scss
    ├── _utilities.scss
    └── _components.scss   # currently monolithic (UC-032)
```

### `GET /components` → `ComponentsController#index`
Component catalogue — one card per component with copy-to-clipboard snippets (UC-005).

### `GET /components/test` → `ComponentsController#test_page`
Single-page render of every component on dummy copy and image placeholders, used as the live regression target for responsiveness (UC-019, UC-033).

---

## 5. Domain Model

### 5.1 `ThemeConfiguration` (PORO)

**Responsibility:** Holds form data, validates inputs, serialises to / deserialises from base64 tokens, and emits the SCSS variable preamble that `ScssCompilerService` prepends to `nanocss.scss`.

```ruby
class ThemeConfiguration
  include ActiveModel::Model

  # Colours
  attr_accessor :primary, :secondary, :tertiary

  # Namespace
  attr_accessor :prefix

  # Typography (4 slots — Heading, Subtitle, Body, Code)
  attr_accessor :font_heading, :font_subtitle, :font_body, :font_code

  # Anchor sizes (Basic Mode anchors all multipliers)
  attr_accessor :base_typography, :base_space, :base_margin,
                :base_radius, :base_border_width

  # Advanced overrides (Advanced Mode decouples the *_md sizes from anchors)
  attr_accessor :margin_md, :space_md

  # Effects (5-part matrices: x, y, blur, spread, colour)
  attr_accessor :text_shadow, :drop_shadow

  # Tier + mode
  attr_accessor :tier            # :core | :standard | :full
  attr_accessor :mode            # :basic | :advanced

  # Component opt-out + layer wrapping
  attr_accessor :excluded_components   # Array<String>
  attr_accessor :wrap_in_layer         # Boolean

  validates :primary, :secondary, :tertiary,
            format: { with: /\A#[0-9a-fA-F]{6}\z/ }
  validates :prefix,
            format: { with: /\A[a-z][a-z0-9-]*[a-z0-9]\z/ },
            length: { maximum: 32 }

  def to_scss_variables_string
    # Outputs:
    #   $prefix: "#{prefix}";
    #   $nanocss-primary: #{primary} !default;
    #   ...
    # The compiler prepends this string to nanocss.scss before compilation.
  end

  def to_base64
    Base64.urlsafe_encode64(attributes.compact.to_json)
  end

  def self.from_base64(token)
    new(JSON.parse(Base64.urlsafe_decode64(token)))
  rescue StandardError
    new # silently fall back to defaults — see UC-018
  end
end
```

**Defaults (current shipped reality):** Corporate preset — `#1e40af / #6366f1 / #06b6d4` — set as the form-load defaults at the end of Sprint 4 (see ADR-004). The original PRD §9.1 palette (`#3b82f6 / #8b5cf6 / #ec4899`) lives on as the *Playful* preset.

### 5.2 `ColourHarmonyService`

**Responsibility:** Calculates Secondary and Tertiary colour suggestions using HSL rotation algorithms based on the user's selected Primary hex.

```ruby
class ColourHarmonyService
  HARMONIES = [:complementary, :analogous, :triadic].freeze
  # Monochromatic + Split-Complementary deferred to UC-037 (Sprint 9)

  def self.call(primary_hex, harmony_type:)
    # Returns [secondary_hex, tertiary_hex]
  end
end
```

The `themes/preview` action invokes this service three times (once per shipped harmony) and renders the swatch buttons via `_harmony_options.html.erb`.

### 5.3 `ScssCompilerService`

**Responsibility:** Orchestrates compilation. Reads the existing on-disk SCSS partials in `app/assets/stylesheets/nanocss/` (read-only — these are hand-authored, not generated), prepends the user's dynamic variable overrides, optionally strips excluded components, optionally wraps the output in `@layer`, and runs `Sass.compile_string`.

```ruby
class ScssCompilerService
  def self.call(theme_configuration, tier: nil, scope: nil)
    # tier:  overrides theme_configuration.tier when present
    # scope: e.g. "#nanocss-preview" — when set, output is wrapped:
    #          #nanocss-preview { /* ...compiled CSS... */ }
    # Returns { css: String, error: String? }
  end
end
```

**Pipeline (7 steps):**
1. Resolve `tier` → list of component partials to include.
2. Apply `excluded_components` regex strips (Buttons?/Loading/Nav aliases handled separately) — see UC-032 for the modular replacement.
3. Build the `$variables` preamble via `ThemeConfiguration#to_scss_variables_string`.
4. Concatenate: preamble + `_variables.scss` + `_mixins.scss` + `_utilities.scss` + `_components.scss` (post-strip).
5. If `wrap_in_layer`, wrap in `@layer #{prefix}.config, #{prefix}.components { ... }`.
6. If `scope`, indent the entire output inside `#{scope} { ... }`.
7. `Sass.compile_string(source, style: :expanded)` → return `{ css:, error: nil }`.

**Dependencies:** `sass` Ruby gem (`Sass.compile_string`). The service is called by `ApplicationController#compile_default_nanocss` on every request to keep the chrome stylesheet in lock-step with the form state — this is the dogfooding hook that **UC-035** depends on.

### 5.4 `GoogleFontsService`

**Responsibility:** Fetches the Google Fonts catalogue, caches it for 24 h, and offers a `valid?(family_name)` whitelist check.

```ruby
class GoogleFontsService
  CATALOGUE_URL = "https://fonts.google.com/metadata/fonts" # undocumented endpoint
  TTL = 24.hours

  def self.catalogue          # Array<{ family:, category:, variants: }>
  def self.valid?(family)     # Boolean
  def self.import_url(family) # https://fonts.googleapis.com/css2?family=...&display=swap
end
```

Used by `ThemeConfiguration` for font-name validation and by `ScssCompilerService` to emit the `@import url(...)` rule at the top of the compiled CSS. **Risk:** the metadata endpoint is undocumented and could change without warning — see ADR-006.

### 5.5 `ZipAssemblerService`

**Responsibility:** Builds the downloadable archive.

```ruby
class ZipAssemblerService
  def self.call(theme_configuration, compiled_css:, compiled_min_css:)
    # Returns String (binary zip) suitable for send_data.
  end
end
```

Uses `rubyzip`. **Known issue (UC-039):** the "minified" output is currently produced by `gsub(/\s+/, ' ')`, which breaks selectors containing significant whitespace. Real minification via `Sass.compile_string(..., style: :compressed)` is scheduled for Sprint 9.

### 5.6 `NanoIconHelper`

**Responsibility:** Renders one of the bundled SVG icons inline with currentColor and `aria-hidden` attributes (UC-021, FR-016).

```ruby
module NanoIconHelper
  ICONS = %i[menu close chevron-down chevron-up arrow-right …].freeze
  def nano_icon(name, size: "1em", **opts); end
end
```

---

## 6. Stylesheet Source Tree

```
app/assets/stylesheets/
├── nanocss/                      # Hand-authored framework source — read-only at runtime
│   ├── _variables.scss           # !default cascade so the preamble can override
│   ├── _mixins.scss
│   ├── _utilities.scss
│   ├── _components.scss          # 741 lines, monolithic (UC-032 splits this)
│   └── nanocss.scss              # entry point — @uses the partials
├── nanocss-compiled/
│   ├── nanocss.css               # produced by ApplicationController hook
│   └── nanocss.min.css           # produced by ZipAssembler (currently 0 bytes — UC-039)
└── application.css               # Custom chrome overrides — UC-036 will reduce this to a thin shell
```

**Critical drift:** The shipped `_components.scss` uses unprefixed selectors for two components (Breadcrumb: `nav[aria-label="breadcrumb"]`; Tooltip: `[data-tooltip]`) that should be prefixed for FR-011 namespacing compliance — UC-030 (Sprint 7) repairs this.

---

## 7. Sprint 5 Reality vs. Sprint 1 Plan

The original Sprint 1 design described a single-mode preview using a `<style>` tag. Five sprints in, the system has the following shape that the original document did not describe:

| Surface | Sprint 1 Plan | Shipped (Sprint 5) | Tracked By |
|---|---|---|---|
| Preview mechanism | Replace `<style>` content via Turbo Stream | Replace `<link href>` → browser refetches `/themes/css?theme=…&preview=true` | ADR-003, UC-016 |
| Default theme | PRD §9.1 (`#3b82f6 / #8b5cf6 / #ec4899`) | Corporate (`#1e40af / #6366f1 / #06b6d4`) | ADR-004, UC-013 |
| Font slots | 3 (Heading, Subtitle, Body) | 4 (+ Code) | PRD v0.4 §9.4 |
| Components | 17 | 20 (+ Card variants, Theme Switcher, Icon Set) | PRD v0.4 §10 |
| Harmonies | 5 (per FR-006) | 3 (Complementary, Analogous, Triadic) | UC-037 (Sprint 9) |
| Dark mode | 3-tier cascade | Tier 2 + Tier 3 only (no `prefers-color-scheme` block) | UC-031 (Sprint 7) |
| PWA | Rejected | Thin install/icon shell only — no offline runtime | ADR-002 |
| Validation enforcement | Pre-compile `valid?` gate | Validators defined but never invoked from controller | UC-023 (Sprint 6) |
| App chrome | Pure nanoCSS dogfood | Custom overrides + 81 inline-style attributes | UC-034, UC-035, UC-036 (Sprint 8) |

---

## 8. Open Architectural Questions (Tracked, Not Resolved)

1. **Modular component partials (UC-032).** Splitting `_components.scss` into `components/_button.scss`, `_nav.scss` etc. would replace the brittle regex-strip in `ScssCompilerService` step 2 with a clean partial-include list. This is queued for Sprint 7.
2. **Real CSS minification (UC-039).** Current `gsub(/\s+/, ' ')` is incorrect. Switching to `Sass.compile_string(..., style: :compressed)` is queued for Sprint 9.
3. **Validator gate (UC-023).** The validation regexes exist but are never enforced. Wiring `unless cfg.valid?` into `#preview` and `#download` is queued for Sprint 6.
4. **Quick Apply re-skin (UC-035).** The link-swap mechanism *does* work — the bug the user reports ("preset buttons don't change the app") is that the *visible app chrome* uses custom CSS, not nanoCSS classes, so swapping the nanoCSS stylesheet has no visible effect on the chrome. Resolved by UC-034 + UC-036.
5. **Google Fonts metadata endpoint (ADR-006).** Undocumented. We will need a fallback to the v1 web-fonts JSON API (with key) if/when this breaks.
