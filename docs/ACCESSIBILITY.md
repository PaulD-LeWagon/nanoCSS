# Accessibility Audit — nanoCSS Configurator

> **Standard:** WCAG 2.1 Level AA  
> **Audit date:** 2026-05-06  
> **Auditor:** UC-045 automated audit (axe-core 4.11.3 + manual contrast calculation)  
> **Audit scope:** All configurator pages + every component on `/components/test`

---

## Summary

| Page | axe-core result | Notes |
|---|---|---|
| Landing page (`/`) | ✅ PASS | No violations found |
| Configure page (`/configure`) | ✅ PASS | No violations found |
| Component Catalogue (`/components`) | ✅ PASS | No violations found |
| Component Test page (`/components/test`) | ✅ PASS | No violations found |

**Overall: PASS** — zero axe-core WCAG 2.1 AA violations on any page.

---

## Automated Testing Setup

axe-core is integrated via `axe-core-rspec` 4.11.3 and runs against every page in
`spec/system/accessibility_spec.rb` using `selenium_chrome_headless`. The spec fires
`be_axe_clean.according_to(:wcag21aa)` which checks all Level A and AA success criteria
detectable via DOM/CSS analysis.

To re-run the audit:

```bash
bundle exec rspec spec/system/accessibility_spec.rb --format documentation
```

---

## AC3 — Semantic Colour Contrast Under All Three Presets

UC-011 generates semantic colours (success, info, warning, danger) by blending 10% of the
preset's primary colour into each semantic base. The contrast check in
`spec/services/semantic_colour_contrast_spec.rb` compiles CSS for each preset and
calculates WCAG 2.1 relative luminance ratios.

### Findings and Fixes

**Original colours (pre-audit):**

| Colour | Base hex | Contrast vs #fff | Contrast vs #111827 | WCAG AA (4.5:1)? |
|---|---|---|---|---|
| Success | #10b981 | ~2.5:1 | ~6.0:1 | ❌ vs white; ✅ vs dark |
| Info | #0ea5e9 | ~3.1:1 | ~5.8:1 | ❌ vs white; ✅ vs dark |
| Warning | #f59e0b | ~2.1:1 | ~7.2:1 | ❌ vs white; ✅ vs dark |
| Danger | #ef4444 | ~3.8:1 | ~4.2:1 | ❌ vs both (contrast gap) |

All four colours failed 4.5:1 with white text. Danger sat in a contrast gap where neither
white nor dark text cleared 4.5:1 with the base colour as shipped.

**Fixes applied (UC-045):**

1. **Badge text colour** (`components/_badges.scss`): Changed from `#fff` to
   `var(--{prefix}-neutral-900, #111827)` for the success, info, and warning variants.
   Dark text achieves ≥ 5.8:1 against all three semantic backgrounds across all presets.

2. **Danger colour darkened** (`_variables.scss` + `ScssCompilerService`): Base danger
   changed from `#ef4444` to `#dc2626`. Danger badges retain white text. After primary
   tinting (10% mix), the compiled danger value achieves ≥ 5.4:1 against white across all
   three presets.

**Post-fix contrast values (Corporate preset):**

| Colour | Compiled hex (approx) | Text colour | Contrast | WCAG AA? |
|---|---|---|---|---|
| Success | #11AD86 | #111827 (dark) | ~6.0:1 | ✅ PASS |
| Info | #10 9AE3 | #111827 (dark) | ~5.8:1 | ✅ PASS |
| Warning | #DF941B | #111827 (dark) | ~7.2:1 | ✅ PASS |
| Danger | #C92934 | #fff (white) | ~5.5:1 | ✅ PASS |

All three presets (Corporate, Playful, Minimalist) verified in
`spec/services/semantic_colour_contrast_spec.rb` — 12 examples, 0 failures.

---

## Known Limitations

### Dark mode contrast

Tier 1 dark mode (`@media (prefers-color-scheme: dark)`) inverts neutral tokens. Dark mode
contrast ratios for semantic coloured components (badges, banners, buttons) have not been
formally verified via axe-core in this sprint because the test environment uses OS light
mode. The `[data-theme="light"]` override on catalogue/configure pages isolates framework
rendering from OS dark mode. A dedicated dark-mode axe-core pass is recommended for a
future sprint.

### Carousel and Loading components

The Carousel (`/components#carousel`) and Loading Spinner (`/components#loading`) do not
contain meaningful text. axe-core flagged no violations. A manual review confirms these
are animation/decorative elements — WCAG 1.1.1 (non-text content) may require `aria-label`
on the spinner for screen readers; flagged for a follow-up story.

---

## How to Re-Audit

```bash
# Browser-based WCAG 2.1 AA (all pages)
bundle exec rspec spec/system/accessibility_spec.rb

# Semantic colour contrast (all 3 presets, compiled CSS)
bundle exec rspec spec/services/semantic_colour_contrast_spec.rb
```
