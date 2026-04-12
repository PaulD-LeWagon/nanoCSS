---
vc-id: 1d6677fe-f2f0-4d18-8102-c49e3e932be5
---
# UX Design & Component Library

> **Project:** nanoCSS
> **Living Document** — updated as new Use Cases introduce new components.
> **Last Updated:** 2026-04-11 (Sprint 1)

---

## Document Purpose

> _This document sits between the Backlog (what to build) and System Design (how to build it).
> It defines the user experience and every UI component before implementation begins,
> so that Acceptance Criteria for front-end Use Cases can reference concrete specifications._

---

## 1. Design Principles

- **Speed over Spectacle:** The preview must be near-instant. Zero lag in the dev loop.
- **Stateless by Design:** No accounts, no barriers to entry.
- **Developer First:** Raw code snippets are front and centre. Errors are verbose and helpful.
- **Accessibility is not optional:** The generated framework must enforce WCAG 2.1 AA defaults.
- **Zero-JS First:** If HTML5/CSS3 can do it natively, use it. Vanilla JS is permitted only where genuinely insufficient.

---

## 2. Design Tokens

### Colour Palette
| Token                    | Value    | Usage                         |
| ------------------------ | -------- | ----------------------------- |
| `--nanocss-primary`      | `#3b82f6`| Primary actions, key CTAs, brand identity |
| `--nanocss-secondary`    | `#8b5cf6`| Secondary brand accents, harmony palettes |
| `--nanocss-tertiary`     | `#ec4899`| Tertiary brand accents, highlights |
| `--nanocss-danger`       | `#ef4444`| Errors, destructive actions   |
| `--nanocss-warning`      | `#f59e0b`| Warnings, cautions            |
| `--nanocss-success`      | `#10b981`| Confirmations, success states |
| `--nanocss-info`         | `#0ea5e9`| Informational banners         |
| `--nanocss-neutral-100`  | `#f3f4f6`| Page/Card backgrounds (light) |
| `--nanocss-neutral-300`  | `#d1d5db`| Borders, dividers             |
| `--nanocss-neutral-500`  | `#6b7280`| Muted text, icons             |
| `--nanocss-neutral-700`  | `#374151`| Body text                     |
| `--nanocss-neutral-900`  | `#111827`| Headings, backgrounds (dark)  |

### Typography
| Token                     | Value                                         | Usage                                                                            |
| ------------------------- | --------------------------------------------- | -------------------------------------------------------------------------------- |
| `--nanocss-font-heading`  | `Dynamic`                                     | All headings (h1–h6). Mapped to Google Fonts.                                    |
| `--nanocss-font-subtitle` | `Dynamic`                                     | Paragraph `<p>` tags inside an `<hgroup>`.                                       |
| `--nanocss-font-body`     | `Dynamic`                                     | Standard body copy. Mapped to Google Fonts.                                      |
| `--nanocss-font-code`     | `Dynamic`                                     | Code, tokens, IDs, preformatted text (`<pre>`, `<code>`).                        |
| `--nanocss-text-xs`       | `calc(var(--nanocss-base-typography) * 0.8)`  | Helper text, footnotes, tooltips.                                                |
| `--nanocss-text-sm`       | `calc(var(--nanocss-base-typography) * 1)`    | Base body text, labels.                                                          |
| `--nanocss-text-md`       | `calc(var(--nanocss-base-typography) * 1.25)` | Subtitles (h4, h5).                                                              |
| `--nanocss-text-lg`       | `calc(var(--nanocss-base-typography) * 1.56)` | Section headers (h3).                                                            |
| `--nanocss-text-xl`       | `calc(var(--nanocss-base-typography) * 1.95)` | Main headers (h2).                                                               |
| `--nanocss-text-xxl`      | `calc(var(--nanocss-base-typography) * 2.44)` | Page headers, Hero text (h1).                                                    |
### Spacing (padding & gaps)

| **Token**             | **Value**                                | **Target**                             |
| --------------------- | ---------------------------------------- | -------------------------------------- |
| `--nanocss-space-xs`  | `calc(var(--nanocss-base-space) * 0.25)` | Micro tweaks.                          |
| `--nanocss-space-sm`  | `calc(var(--nanocss-base-space) * 0.5)`  | Tight spacing, standard component gap. |
| `--nanocss-space-md`  | `calc(var(--nanocss-base-space) * 1)`    | Standard spacing.                      |
| `--nanocss-space-lg`  | `calc(var(--nanocss-base-space) * 1.5)`  | Section separation.                    |
| `--nanocss-space-xl`  | `calc(var(--nanocss-base-space) * 2)`    | Loose spacing.                         |
| `--nanocss-space-xxl` | `calc(var(--nanocss-base-space) * 3)`    | Major layout sections.                 |

> [!NOTE]
> The implementation agent will map `$nanocss-base-margin`, `$nanocss-base-radius`, and `$nanocss-base-border-width` through this exact same multiplier scale.

### Breakpoints
| Name | Value | Target |
|---|---|---|
| `sm` | `576px` | Large phones / small tablets |
| `md` | `768px` | Tablets |
| `lg` | `992px` | Laptops |
| `xl` | `1200px` | Desktops |

---

## 3. User Journey Maps

### Journey 1: Configure & Download
**Entry point:** Landing Page URL
**Goal:** User configures a custom theme and downloads the SCSS/CSS archive.

| Step | User Action | System Response | Emotional State | Friction Points |
|---|---|---|---|---|
| 1 | Clicks a preset theme card | Instantly applies design tokens to preview pane | 😐 Neutral | Waiting for page reload (Mitigated by Hotwire) |
| 2 | Adjusts Primary Colour Hex | Turbo updates `<style>`, Harmony generator populates options | 🙂 Engaged | Entering an invalid hex code (Mitigated by server-side validation/UI highlight) |
| 3 | Toggles "Advanced Mode" | Accordions expand revealing granular spacing/border inputs | 🙂 Engaged | Overwhelming options (Mitigated by hiding them by default) |
| 4 | Selects "Standard" Tier | Internal model flags component exclusions | 😊 Satisfied | Unsure what "Standard" means (Requires clear UI tooltip/subtext) |
| 5 | Clicks "Download" button | Streams `nanocss.zip` directly to browser | 😊 Satisfied | Download delay (Mitigated by in-memory Sass compile) |

**Success state:** ZIP file downloads; user extracts it to find ready-to-use CSS and modular SCSS files.
**Failure states:** Compiler fails due to extreme variable overrides. UI displays an inline toast error and disables the Download button until resolved.

---

## 4. Page / Screen Inventory

| ID | Screen Name | Route | Use Cases Served | Status |
|---|---|---|---|---|
| SCR-001 | Landing Page | `/` | UC-001 | 🟡 Designed |
| SCR-002 | Configuration | `/configure` | UC-002, UC-003, UC-004, UC-006 | 🟡 Designed |
| SCR-003 | Component Catalogue | `/components` | UC-005 | ⚪ To Design |

---

## 5. Component Specifications (Generator App UI)

### `<ConfigSidebar>`
**Used in:** SCR-002, UC-002
**Description:** The primary form interface for adjusting design tokens, driving the live Turbo Stream preview.

#### Props / Inputs
| Prop | Type | Required | Default | Description |
|---|---|---|---|---|
| `theme_configuration` | `Object` | Yes | `nil` | The ActiveModel PORO containing current user selections |

#### States
| State | Description | Visual Notes |
|---|---|---|
| **Default (Basic)** | Standard view | Shows only primary colours, font selectors, and anchor size/space inputs. |
| **Advanced** | Expanded view | Unhides individual scale overrides and namespace prefix input. |
| **Error** | Invalid input detected | Red border around offending input; inline helper text displays error reason. |

#### Interaction Specification
| Trigger | Behaviour |
|---|---|
| Input change (blur or 300ms debounce) | Submits form silently via Turbo; updates PreviewPane DOM. |
| Harmony Swatch click | Populates Secondary/Tertiary hex inputs and triggers form submit. |
| "Reset" click | Restores all form inputs to base `variables.scss` defaults. |

#### Wireframe / Sketch
```

┌─────────────────────────────────────┐
│  Theme Configuration (Default)      │
│                                     │
│  Primary:   [ #3B82F6 ] (Picker)    │
│  Secondary: [ #8B5CF6 ] (Picker)    │
│  Tertiary:  [ #EC4899 ] (Picker)    │
│                                     │
│  [ Theme Swatch Presets ]           │
│                                     │
│  Headings Font: [ Inter ▼ ]         │
│  Subtitle Font: [ Inter ▼ ]         │
│  Body Font:     [ Roboto ▼ ]        │
│  Code Font:     [ Fira Code ▼ ]     │
│                                     │
│  Typography Base:    [ 1rem ]       │
│  Spacing Base:       [ 0.5rem ]     │
│  Border Radius Base: [ 0.25rem ]    │
│  Border Width Base:  [ 2px ]        │
│                                     │
│  > Advanced Options (toggle)        │
│                                     │
│  [ Download nanoCSS ]               │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│  Theme Configuration (Advanced)     │
│                                     │
│  Primary:   [ #3B82F6 ] (Picker)    │
│  Secondary: [ #8B5CF6 ] (Picker)    │
│  Tertiary:  [ #EC4899 ] (Picker)    │
│                                     │
│  [ Theme Swatch Presets ]           │
│                                     │
│  Headings Font: [ Inter ▼ ]         │
│  Subtitle Font: [ Inter ▼ ]         │
│  Body Font:     [ Roboto ▼ ]        │
│  Code Font:     [ Fira Code ▼ ]     │
│                                     │
│  Typography Base:    [ 1rem ]       │
│  Spacing Base:       [ 0.5rem ]     │
│  Border Radius Base: [ 0.25rem ]    │
│  Border Width Base:  [ 1px ]        │
│  Margin Base:        [ 1.25rem ]    │
│                                     │
│  Text Shadow:                       │
│  [ .25rem ] [ .25rem ] [ .5rem ]    │
│  [ #050505 ] [ 0.5 opacity ]        │
│                                     │
│  Drop Shadow:                       │
│  [ .5rem ] [ .5rem ] [ 1rem ]       │
│  [ #010101 ] [ 0.25 ] [ ] Inset     │
│                                     │
│  [ Download nanoCSS ]               │
└─────────────────────────────────────┘

```

---

### `<PreviewPane>`
**Used in:** SCR-001, SCR-002, UC-001, UC-002
**Description:** A stateless display pane that renders a representative HTML document against the dynamically compiled CSS string.

#### Props / Inputs
| Prop | Type | Required | Default | Description |
|---|---|---|---|---|
| `css_payload` | `String` | Yes | `""` | The raw CSS compiled by Dart Sass. |

#### States
| State | Description | Visual Notes |
|---|---|---|
| **Default** | Rendered | Displays HTML components using the injected `<style>`. |
| **Updating** | Turbo request in flight | Subtle opacity drop (e.g., `opacity: 0.7`) to indicate network latency. |

#### Interaction Specification
| Trigger | Behaviour |
|---|---|
| Turbo Stream broadcast received | Replaces inner HTML of the target `<style>` tag. |

---

## 6. Component Specifications (Target Framework Catalogue)

> _These are the 18 specific framework components generated BY the tool, as outlined in the PRD. They will be displayed in the Component Catalogue (SCR-003). Note: All classes assume the default `nanocss-` prefix._

### 0. `<Text Banner>`
**Used in:** SCR-003, UC-005
**Description:** A semantically grouped headline and subtitle layout.

#### Props / Inputs
| Prop | Type | Required | Default | Description |
|---|---|---|---|---|
| `HTML Elements` | `Tags` | Yes | `N/A` | `<hgroup>`, `<h1>`, `<p>` |

#### States
| State | Description | Visual Notes |
|---|---|---|
| **Default** | Standard typography | `<h1>` uses `--font-heading`, `<p>` uses `--font-subtitle`. Tightened margin between the two elements. |

#### Interaction Specification
| Trigger | Behaviour |
|---|---|
| Responsive resize | Font sizes scale fluidly via `clamp()`. |

#### Wireframe / Sketch
```
┌─────────────────────────────────────┐
│                                     │
│  # Main Headline Here               │
│  This is the supporting subtitle    │
│  text directly underneath.          │
│                                     │
└─────────────────────────────────────┘
```

---

### 1. `<Hero Banner>`
**Used in:** SCR-003, UC-005
**Description:** A large, prominent section designed to grab attention at the top of a page.

#### Props / Inputs
| Prop | Type | Required | Default | Description |
|---|---|---|---|---|
| `HTML Elements` | `Tags` | Yes | `N/A` | `<section class="nanocss-hero">`, plus Text Banner elements. |

#### States
| State | Description | Visual Notes |
|---|---|---|
| **Default** | Full width | Background utilizes neutral or primary tint. Padding uses `--space-6`. Minimum height established (e.g. `50vh`). Center aligned content. |

#### Interaction Specification
| Trigger | Behaviour |
|---|---|
| Viewport resize | Padding and text scales. Flexbox ensures vertical centering is maintained. |

#### Wireframe / Sketch
```
┌─────────────────────────────────────┐
│                                     │
│                                     │
│        # Big Hero Headline          │
│        Supporting value prop.       │
│             [ CTA Button ]          │
│                                     │
│                                     │
└─────────────────────────────────────┘
```

---

### 2. `<Carousel>`
**Used in:** SCR-003, UC-005
**Description:** A horizontal scrolling container for items, driven entirely by CSS scroll snap.

#### Props / Inputs
| Prop | Type | Required | Default | Description |
|---|---|---|---|---|
| `HTML Elements` | `Tags` | Yes | `N/A` | `<div class="nanocss-carousel">` wrapping multiple items. |

#### States
| State | Description | Visual Notes |
|---|---|---|
| **Default** | Overflowing horizontally | Items displayed in a row, hiding overflow to the right. |

#### Interaction Specification
| Trigger | Behaviour |
|---|---|
| User swipes/scrolls horizontally | CSS `scroll-snap-type: x mandatory` snaps elements to the start or center of the container viewport. Zero JS required. |

#### Wireframe / Sketch
```
┌─────────────────────────────────────┐
│ ┌────────┐ ┌────────┐ ┌────────┐    │
│ │ Item 1 │ │ Item 2 │ │ Item 3 │ >  │
│ └────────┘ └────────┘ └────────┘    │
└─────────────────────────────────────┘
```

---

### 3. `<Accordion>`
**Used in:** SCR-003, UC-005
**Description:** Collapsible content panels utilizing native HTML interactive elements.

#### Props / Inputs
| Prop | Type | Required | Default | Description |
|---|---|---|---|---|
| `HTML Elements` | `Tags` | Yes | `N/A` | `<details>`, `<summary>` |

#### States
| State | Description | Visual Notes |
|---|---|---|
| **Closed (Default)**| Content hidden | Only the `<summary>` text is visible, styled like a clickable row, often with a `+` or `>` chevron indicator. |
| **Open** | Content visible | The sibling content below the `<summary>` is displayed block. Chevron rotates. |

#### Interaction Specification
| Trigger | Behaviour |
|---|---|
| User clicks `<summary>` | Native browser behaviour expands the `<details>` element. CSS styles the open state using `details[open] summary`. Zero JS. |

#### Wireframe / Sketch
```
┌─────────────────────────────────────┐
│  > Accordion Title 1                │
│ ─────────────────────────────────── │
│  v Accordion Title 2                │
│    Here is the hidden content       │
│    that is now revealed.            │
│ ─────────────────────────────────── │
│  > Accordion Title 3                │
└─────────────────────────────────────┘
```

---

### 4. `<Card>`
**Used in:** SCR-003, UC-005
**Description:** A flexible, bordered container for grouping related content.

#### Props / Inputs
| Prop | Type | Required | Default | Description |
|---|---|---|---|---|
| `HTML Elements` | `Tags` | Yes | `N/A` | `<article class="nanocss-card">`, optional `<header>`, `<footer>`. |

#### States
| State | Description | Visual Notes |
|---|---|---|
| **Default** | Standard display | Border uses `--nanocss-neutral-300`, background `--nanocss-neutral-100`. Border-radius uses `--nanocss-radius-md`. |
| **Hover (Optional)**| Interactive context | Subtle elevation via `--nanocss-shadow-md` if linked. |

#### Interaction Specification
| Trigger | Behaviour |
|---|---|
| None (Static) | Flexbox column layout ensures footer is pushed to the bottom if cards in a grid have unequal content height. |

#### Wireframe / Sketch
```
┌─────────────────────────────────────┐
│ ┌───────────────────────────┐       │
│ │ [ Image Optional ]        │       │
│ ├───────────────────────────┤       │
│ │ Header Title              │       │
│ │ Body content goes here... │       │
│ │                           │       │
│ ├───────────────────────────┤       │
│ │ Footer actions      [Btn] │       │
│ └───────────────────────────┘       │
└─────────────────────────────────────┘
```

---

### 5. `<Dropdown>`
**Used in:** SCR-003, UC-005
**Description:** A contextual menu revealing a list of links or actions.

#### Props / Inputs
| Prop | Type | Required | Default | Description |
|---|---|---|---|---|
| `HTML Elements` | `Tags` | Yes | `N/A` | Container wrapping a button and a hidden `<ul>`. |

#### States
| State | Description | Visual Notes |
|---|---|---|
| **Closed (Default)**| Menu hidden | Only trigger button visible. |
| **Open** | Menu visible | List appears absolutely positioned below trigger. Elevated via `--nanocss-shadow-lg`. Z-index: `1000`. |

#### Interaction Specification
| Trigger | Behaviour |
|---|---|
| User clicks trigger | Requires either a `<details>` element hack or a tiny Vanilla JS toggle to add/remove a `.show` class. Focus management required for accessibility. |

#### Wireframe / Sketch
```
┌─────────────────────────────────────┐
│  [ Actions ▼ ]                      │
│  ┌────────────────┐                 │
│  │ Action 1       │                 │
│  │ Action 2       │                 │
│  │─────────────── │                 │
│  │ Danger Action  │                 │
│  └────────────────┘                 │
└─────────────────────────────────────┘
```

---

### 6. `<Group>`
**Used in:** SCR-003, UC-005
**Description:** A layout wrapper to visually connect adjacent inputs or buttons.

#### Props / Inputs
| Prop | Type | Required | Default | Description |
|---|---|---|---|---|
| `HTML Elements` | `Tags` | Yes | `N/A` | `<div class="nanocss-group">` |

#### States
| State | Description | Visual Notes |
|---|---|---|
| **Default** | Joined | Removes internal border-radii between adjacent children. Uses flexbox to keep them on one line. |

#### Interaction Specification
| Trigger | Behaviour |
|---|---|
| Focus | Focus rings must be styled to pop above adjacent elements to remain visible. |

#### Wireframe / Sketch
```
┌─────────────────────────────────────┐
│ ┌───────────────┬────────┐          │
│ │ Search...     │ Submit │          │
│ └───────────────┴────────┘          │
└─────────────────────────────────────┘
```

---

### 7. `<Loading>`
**Used in:** SCR-003, UC-005
**Description:** A visual indicator for asynchronous operations.

#### Props / Inputs
| Prop | Type | Required | Default | Description |
|---|---|---|---|---|
| `HTML Elements` | `Tags` | Yes | `N/A` | `<span class="nanocss-loader">` |

#### States
| State | Description | Visual Notes |
|---|---|---|
| **Default** | Spinning | A circular element with a partially transparent border and a solid border top, rotating infinitely. |

#### Interaction Specification
| Trigger | Behaviour |
|---|---|
| None | CSS `@keyframes` rotation. Requires `aria-busy="true"` on parent container for accessibility. |

#### Wireframe / Sketch
```
┌─────────────────────────────────────┐
│                                     │
│                 ↻                   │
│                                     │
└─────────────────────────────────────┘
```

---

### 8. `<Modal>`
**Used in:** SCR-003, UC-005
**Description:** A native HTML5 dialog overlay for critical interactions or forms.

#### Props / Inputs
| Prop | Type | Required | Default | Description |
|---|---|---|---|---|
| `HTML Elements` | `Tags` | Yes | `N/A` | `<dialog class="nanocss-modal">` |

#### States
| State | Description | Visual Notes |
|---|---|---|
| **Closed (Default)**| Hidden from view | `display: none` natively applied by browser. |
| **Open** | Modal visible | Centered over screen. `::backdrop` has `rgba(0,0,0,0.5)` background. Z-index: `1040`. |

#### Interaction Specification
| Trigger | Behaviour |
|---|---|
| User clicks Trigger | Vanilla JS calls `document.getElementById('modal').showModal()`. |
| User clicks Close | Vanilla JS calls `document.getElementById('modal').close()`. |
| Escape Key | Native browser behaviour closes the `<dialog>`. |

#### Wireframe / Sketch
```
┌─────────────────────────────────────┐
│  (Backdrop overlay)                 │
│      ┌───────────────────────┐      │
│      │ Modal Title        [X]│      │
│      │                       │      │
│      │ [Body text content]   │      │
│      │                       │      │
│      │      [Cancel] [Confirm]      │
│      └───────────────────────┘      │
└─────────────────────────────────────┘
```

---

### 9. `<Nav / NavBar>`
**Used in:** SCR-003, UC-005
**Description:** Top-level site navigation wrapper with responsive considerations.

#### Props / Inputs
| Prop | Type | Required | Default | Description |
|---|---|---|---|---|
| `HTML Elements` | `Tags` | Yes | `N/A` | `<nav class="nanocss-nav">` |

#### States
| State | Description | Visual Notes |
|---|---|---|
| **Desktop** | Horizontal | Links aligned inline via flexbox. |
| **Mobile** | Stacked / Hidden | Links hidden behind a hamburger menu toggle. |

#### Interaction Specification
| Trigger | Behaviour |
|---|---|
| Viewport drops below `md` breakpoint | Media query alters flex direction. Toggle button becomes visible. Vanilla JS required to toggle mobile menu visibility. |

#### Wireframe / Sketch
```
┌─────────────────────────────────────┐
│ [Logo]         Link 1  Link 2  [Btn]│
└─────────────────────────────────────┘
```

---

### 10. `<Progress>`
**Used in:** SCR-003, UC-005
**Description:** Native HTML5 progress bar styling.

#### Props / Inputs
| Prop | Type | Required | Default | Description |
|---|---|---|---|---|
| `HTML Elements` | `Tags` | Yes | `N/A` | `<progress value="x" max="y">` |

#### States
| State | Description | Visual Notes |
|---|---|---|
| **Default** | Track and fill | Background track is neutral; fill uses `--nanocss-primary`. Inherits `--nanocss-radius-pill`. |

#### Interaction Specification
| Trigger | Behaviour |
|---|---|
| Value attribute changes | CSS handles the width of the pseudo-elements (`::-webkit-progress-value`, `::-moz-progress-bar`). |

#### Wireframe / Sketch
```
┌─────────────────────────────────────┐
│                                     │
│ [█████████▒▒▒▒▒▒▒▒▒▒▒] 45%          │
│                                     │
└─────────────────────────────────────┘
```

---

### 11. `<Tooltip>`
**Used in:** SCR-003, UC-005
**Description:** CSS-only contextual text bubbles.

#### Props / Inputs
| Prop | Type | Required | Default | Description |
|---|---|---|---|---|
| `HTML Elements` | `Attr` | Yes | `N/A` | `data-tooltip="Message"` |

#### States
| State | Description | Visual Notes |
|---|---|---|
| **Default** | Hidden | Opacity 0, pointer-events none. |
| **Hover/Focus** | Visible | Opacity 1. Dark background, white text. Uses `::before` (triangle) and `::after` (bubble). |

#### Interaction Specification
| Trigger | Behaviour |
|---|---|
| Hover or Focus | CSS transition reveals the pseudo-elements. Zero JS. |

#### Wireframe / Sketch
```
┌─────────────────────────────────────┐
│                                     │
│          ┌────────────┐             │
│          │ Helpful!   │             │
│          └─────v──────┘             │
│            [ Hover Me ]             │
└─────────────────────────────────────┘
```

---

### 12. `<Buttons>`
**Used in:** SCR-003, UC-005
**Description:** Interactive action elements.

#### Props / Inputs
| Prop | Type | Required | Default | Description |
|---|---|---|---|---|
| `HTML Elements` | `Tags` | Yes | `N/A` | `<button>`, `a.btn` |

#### States
| State | Description | Visual Notes |
|---|---|---|
| **Primary** | Main action | Solid `--nanocss-primary` background, white text. |
| **Secondary** | Alt action | Transparent background, `--nanocss-primary` border and text. |
| **Hover** | Mouse over | Slightly darkened background via SCSS `color.mix()` with black. |
| **Active** | Clicked | Subtle CSS `transform: scale(0.98)` for tactile feedback. |
| **Disabled** | Non-interactive | Opacity reduced, cursor `not-allowed`. |

#### Interaction Specification
| Trigger | Behaviour |
|---|---|
| Focus | Obvious outline ring utilizing the primary colour tinted with transparency. |

#### Wireframe / Sketch
```
┌─────────────────────────────────────┐
│                                     │
│  [ Primary ]  [ Secondary ]         │
│                                     │
└─────────────────────────────────────┘
```

---

### 13. `<Badges>`
**Used in:** SCR-003, UC-005
**Description:** Small inline indicators for counts or status.

#### Props / Inputs
| Prop | Type | Required | Default | Description |
|---|---|---|---|---|
| `HTML Elements` | `Tags` | Yes | `N/A` | `<span class="nanocss-badge">` |

#### States
| State | Description | Visual Notes |
|---|---|---|
| **Default** | Status indicator | Tiny font (`--text-xs`), bold weight, pill border radius. Uses semantic colours (Success, Warning, Danger). |

#### Interaction Specification
| Trigger | Behaviour |
|---|---|
| None | Static visual element. |

#### Wireframe / Sketch
```
┌─────────────────────────────────────┐
│                                     │
│  Messages (New!)                    │
│                                     │
└─────────────────────────────────────┘
```

---

### 14. `<Tags>`
**Used in:** SCR-003, UC-005
**Description:** Dismissible categorical labels.

#### Props / Inputs
| Prop | Type | Required | Default | Description |
|---|---|---|---|---|
| `HTML Elements` | `Tags` | Yes | `N/A` | `<span class="nanocss-tag">` containing text and a close `<button>`. |

#### States
| State | Description | Visual Notes |
|---|---|---|
| **Default** | Displayed | Similar to badges but larger, with a distinct visual separator for the close action (an 'x'). |

#### Interaction Specification
| Trigger | Behaviour |
|---|---|
| Click close button | Vanilla JS removes the parent tag element from the DOM. |

#### Wireframe / Sketch
```
┌─────────────────────────────────────┐
│                                     │
│  [ Ruby x ]  [ Rails x ]            │
│                                     │
└─────────────────────────────────────┘
```

---

### 15. `<Breadcrumbs>`
**Used in:** SCR-003, UC-005
**Description:** Navigational hierarchy path.

#### Props / Inputs
| Prop | Type | Required | Default | Description |
|---|---|---|---|---|
| `HTML Elements` | `Tags` | Yes | `N/A` | `<nav aria-label="breadcrumb"><ol>` |

#### States
| State | Description | Visual Notes |
|---|---|---|
| **Default** | Inline list | List items display inline. Separators (e.g., `/` or `>`) added automatically via CSS `::after` on `<li>` elements, excluding the last child. |

#### Interaction Specification
| Trigger | Behaviour |
|---|---|
| None | Static navigational links. Current page should have `aria-current="page"`. |

#### Wireframe / Sketch
```
┌─────────────────────────────────────┐
│                                     │
│  Home / Products / Shoes            │
│                                     │
└─────────────────────────────────────┘
```

---

### 16. `<Pagination>`
**Used in:** SCR-003, UC-005
**Description:** Page navigation controls for large data sets.

#### Props / Inputs
| Prop | Type | Required | Default | Description |
|---|---|---|---|---|
| `HTML Elements` | `Tags` | Yes | `N/A` | `<nav><ul class="nanocss-pagination">` |

#### States
| State | Description | Visual Notes |
|---|---|---|
| **Default** | Numbered list | Flexbox row of square/circular buttons. Active page has primary background. |
| **Disabled** | Bounds reached | Previous/Next buttons visually disabled when on first/last page. |

#### Interaction Specification
| Trigger | Behaviour |
|---|---|
| Hover / Focus | Unselected pages mirror standard button hover states. |

#### Wireframe / Sketch
```
┌─────────────────────────────────────┐
│                                     │
│  [<] [1] [2] [3] [>]                │
│                                     │
└─────────────────────────────────────┘
```

---

### 17. `<Tabs>`
**Used in:** SCR-003, UC-005
**Description:** A purely CSS-driven tabbed interface.

#### Props / Inputs
| Prop | Type | Required | Default | Description |
|---|---|---|---|---|
| `HTML Elements` | `Tags` | Yes | `N/A` | `<input type="radio">`, `<label>`, `<div class="panel">` |

#### States
| State | Description | Visual Notes |
|---|---|---|
| **Default** | First tab selected | Active tab label bolded with `--nanocss-primary` bottom border. |
| **Inactive Panel** | Unselected tab content | `display: none` applied via CSS. |

#### Interaction Specification
| Trigger | Behaviour |
|---|---|
| User clicks Tab Label | Correlated hidden radio input becomes `:checked`. CSS `:has()` or sibling `~` selector reveals corresponding panel. Zero JS. |

#### Wireframe / Sketch
```
┌─────────────────────────────────────┐
│ [Tab 1 Active]  [Tab 2]  [Tab 3]    │
│ ─────────────────────────────────── │
│  Active panel content displayed     │
│  here...                            │
└─────────────────────────────────────┘
```

---

## 7. Shared / Global UI Patterns

### Form Validation Pattern
- Validate **on blur** (when user leaves a field) — not on every keystroke.
- Validate **on submit** as a final gate.
- Error messages placed **below** the relevant field.

### Loading States Pattern
- Any action taking > 300ms shows a loading indicator.
- Buttons disable during async operations.

### Empty States Pattern
- Lists or tables without data must render a designed empty state.
- Empty state includes: icon + heading + optional helper text + optional CTA.

### Toast / Notification Pattern
- **Success:** Green `--nanocss-success`, bottom-right, auto-dismiss after 3 seconds (e.g., "Copied to clipboard!").
- **Error:** Red `--nanocss-danger`, top-right, persists until dismissed.
- Maximum 1 toast visible at a time.

---

## 8. Accessibility Checklist

- [ ] All interactive elements reachable and operable by keyboard alone.
- [ ] Focus indicator is visible on all interactive elements (no `outline: none` without replacement).
- [ ] Colour contrast ratio ≥ 4.5:1 for body text, ≥ 3:1 for large text.
- [ ] No information conveyed by colour alone (always paired with text or icon).
- [ ] All images have descriptive `alt` text (or `alt=""` if purely decorative).
- [ ] All form fields have associated `<label>` elements.
- [ ] Error messages are programmatically associated with their field (`aria-describedby`).
- [ ] Page has a logical heading hierarchy (one `<h1>`, no skipped levels).
- [ ] Dynamic content changes are announced to screen readers (`aria-live`).

---

## Revision History

| Version | Date | Author | Summary |
|---|---|---|---|
| 0.1 | 2026-04-11 | Big Kahuna (Gemini) | Initial draft — Sprint 1 App UI and full 18-component Framework Catalogue |