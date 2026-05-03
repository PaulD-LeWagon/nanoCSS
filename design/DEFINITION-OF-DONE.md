# Definition of Done — nanoCSS Configurator

> **Project:** nanoCSS
> **Purpose:** Every story must pass every applicable gate before status changes to `done`.
> "Tests are green" and "this is production-ready" must mean the same thing.

---

## Universal Gates (every story, no exceptions)

- [ ] All Acceptance Criteria for the Use Case are met
- [ ] `bundle exec rspec` — exits 0, no skipped specs without a dated comment
- [ ] `bundle exec rubocop` — exits 0, no offences
- [ ] `bundle exec brakeman --no-pager` — no new warnings introduced
- [ ] **[CRITICAL] Before/after visual comparison** — screenshot every affected page/component *before* starting, screenshot again *after* implementing, compare side-by-side before committing. Any visual element that disappears without explicit authorisation in the story's ACs is a regression — stop, restore, flag.
- [ ] Story committed with Conventional Commit: `type(scope): description [UC-NNN]`
- [ ] `design/BACKLOG.md` updated — story status → `🟢 Done`
- [ ] `design/SPRINT-PLAN.md` updated — story table status → `done`
- [ ] `design/CHANGELOG.md` `## [Unreleased]` section updated

---

## Conditional Gates

### If the story changes `ThemeConfiguration` attributes or defaults:
- [ ] `ThemeConfiguration#to_base64` + `from_base64` round-trip spec passes
- [ ] `ThemeConfiguration#to_scss_variables_string` spec covers the new attribute
- [ ] `design/SYSTEM_DESIGN.md §5.1` interface table updated

### If the story changes a controller action or adds a route:
- [ ] `design/SYSTEM_DESIGN.md §4` (Internal API Contracts) updated
- [ ] Request spec added or updated

### If the story changes SCSS component output:
- [ ] Visual regression screenshot attached to the story (before + after)
- [ ] All 20 components still render on `/components/test` without layout failures
- [ ] `nanocss.min.css` in `nanocss-compiled/` regenerated (run `rails server` briefly to trigger `compile_default_nanocss`)

### If the story adds a new service or changes a service interface:
- [ ] `design/SYSTEM_DESIGN.md §5` updated with new/changed interface
- [ ] `RSpec` unit spec for the service's `.call` method covers the happy path + at least one error path

### If the story introduces a non-obvious architectural decision:
- [ ] New ADR written in `design/ARCHITECTURE_DECISIONS.md`
- [ ] ADR index table updated

### If the story changes the preview mechanism or link-swap flow:
- [ ] System spec exercising the Turbo Stream + browser fetch passes
- [ ] Spec does **not** assert on `<style>` tag content — only on `<link href>` (per ADR-003)

---

## Never Ship If:
- Any spec is failing (including the 4 pre-existing failures — UC-026 must fix, not `skip`)
- A new inline `style="…"` attribute was added to a view (UC-034 is deleting them all)
- A new `@import` or `url()` was added to SCSS without going through `GoogleFontsService.valid?`
- A new gem was added without updating `design/PRD.md §11.3` (Gem Dependencies)
- The `app/assets/stylesheets/nanocss/_*.scss` source files were edited without an explicit UC instructing it
- **A UI/UX feature visible before the story started is absent after it, unless the story explicitly authorises removal** — "refactor" and "replace" do not grant permission to drop functionality or visual elements
