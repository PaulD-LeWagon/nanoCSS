# CLAUDE.md — nanoCSS Configurator (Project-Specific Overrides)

> **Read `AGENTS.md` first.** That symlinked file is the authoritative master operating manual
> for every agent on this machine. This file contains **nanoCSS-specific overrides only**.
> Where this file conflicts with `AGENTS.md`, **this file wins**.
> Keep this file under 200 lines. Update when conventions change.

---

## Project Overview

- **Name:** nanoCSS Configurator
- **What it does:** Stateless Rails app where indie devs configure, preview, and download a
  custom-namespaced CSS framework (nanoCSS) — colours, fonts, spacing, components — compiled
  on the fly via Dart Sass.
- **Stack:** Rails 7.2.3 · Ruby 3.3 · **No database** · Hotwire (Turbo Streams + Stimulus) ·
  importmap-rails · Dart Sass (`sass` gem) · rubyzip · RSpec + Selenium/Capybara
- **Architecture:** Fully stateless. No ActiveRecord models. No Devise. No auth of any kind.
  POROs + ActiveModel::Model only.
- **Current Sprint:** See `design/BACKLOG.md` header and `design/SPRINT-PLAN.md`

---

## Anti-Bias Reminders (Highest-Risk Items)

Re-read before each story. Claude's training biases will try to push you toward the wrong things.

- **No database.** Do not generate migrations, models, `schema.rb`, seeds, or any
  ActiveRecord code. There is no DB. `ThemeConfiguration` is a PORO.
- **No auth.** No Devise, no Pundit, no `current_user`, no sessions. The app is public.
- **Styling:** Use nanoCSS utility classes only — no Tailwind, no Bootstrap, no inline
  `style=` attributes (UC-034 is deleting them). Use `.{prefix}-*` semantic class names.
- **Frontend:** Hotwire only. No React, no Vue, no `.jsx`/`.tsx`. Turbo Streams for
  server-driven updates; Stimulus for progressive enhancement.
- **Tests:** RSpec + Selenium/Capybara. **Not** Cuprite (that's ProjectX). **Not** Minitest.
- **SCSS compilation:** `Sass.compile_string` via the `sass` gem. **Never** shell out to
  `sassc` or `node-sass`.

---

## Key Files

| File | Purpose |
|---|---|
| `app/models/theme_configuration.rb` | PORO — the only "model". `ActiveModel::Model`. |
| `app/services/scss_compiler_service.rb` | 7-step in-process Dart Sass pipeline |
| `app/services/colour_harmony_service.rb` | HSL rotation algorithms for palette suggestions |
| `app/services/google_fonts_service.rb` | Catalogue cache + whitelist guard |
| `app/services/zip_assembler_service.rb` | rubyzip download builder |
| `app/controllers/themes_controller.rb` | index / show / preview / css / download |
| `app/assets/stylesheets/nanocss/` | Hand-authored framework SCSS — **read-only at runtime** |
| `design/BACKLOG.md` | Prioritised Use Cases — the source of truth for sprint planning |
| `design/PRD.md` | v0.4 — retrofitted to shipped reality |
| `design/SYSTEM_DESIGN.md` | v0.4 — architecture, service interfaces, domain model |
| `design/ARCHITECTURE_DECISIONS.md` | ADR-001 through ADR-006 — the why behind key decisions |
| `design/CHANGELOG.md` | Release history v0.1.0 → v0.5.0 |
| `design/SPRINT-PLAN.md` | Current sprint velocity + retrospective (see also BACKLOG.md) |

---

## Commands

```bash
bin/rails server                    # Start the app
bin/rails console                   # REPL (no DB — POROs only)

bundle exec rspec                   # Full suite (81 specs; 4 currently failing — UC-026)
bundle exec rspec spec/models       # Unit specs
bundle exec rspec spec/services     # Service specs
bundle exec rspec spec/system       # Selenium system specs

bundle exec rubocop                 # Style check
bundle exec rubocop -a              # Autocorrect safe offences
bundle exec brakeman --no-pager     # Security scan
```

---

## Coding Conventions

- **Ruby style:** `rubocop-rails-omakase` defaults.
- **Controllers:** thin. Parse params → build `ThemeConfiguration` → call service → render.
  No business logic in controllers.
- **Services:** business logic lives here. Single public `.call` class method.
- **Stimulus controllers:** progressive enhancement only. Server is authoritative.
- **Turbo Streams:** respond via `.turbo_stream.erb` templates. The preview stream replaces
  `<link id="nanocss-preview-link">` — **not** a `<style>` tag (see ADR-003).
- **Comments:** explain *why*, not *what*. Link to ADR where relevant (e.g. `# Per ADR-003`).
- **Commits:** `type(scope): description [UC-NNN]` — e.g.
  `feat(themes): wire validator gate before compiler call [UC-023]`

---

## Hard Do-Nots

- **Never** add a `before_action :authenticate_user!` — there is no auth
- **Never** call `Model.find(id)` — there are no AR models
- **Never** run `rails db:migrate` — there is no schema
- **Never** touch `app/assets/stylesheets/nanocss/_*.scss` production files without
  an explicit UC telling you to (they are hand-authored source — read-only at runtime)
- **Never** ship `nanocss.min.css` using `gsub(/\s+/, ' ')` — that is the known-broken
  placeholder. Real minification is UC-040 (Sprint 9): `Sass.compile_string(style: :compressed)`
- **Never** inline-style `style="..."` in views — UC-034 is deleting all 81 of them
- **Never** mark a story done without running RuboCop + Brakeman + RSpec all green

---

## Known Gotchas

- **4 specs are intentionally failing** as of Sprint 5 close. They assert pre-Sprint-4
  defaults and the old `<style>`-tag preview. UC-026 (Sprint 6) repairs them — do not
  paper over them with `skip` or `pending`.
- **`ThemeConfiguration` validators exist but are never called from the controller.**
  This is tracked as UC-023 (Sprint 6) — the first story of the next sprint.
- **The `excluded_components` regex-strip is brittle.** `Buttons?/Loading/Nav` have
  special-case handling. UC-032 (Sprint 7) replaces this with a modular include-list.
- **`compile_default_nanocss` runs on every request.** This is intentional dogfooding —
  `ApplicationController` hooks it so the chrome stylesheet stays in sync with the form state.

---

## Workflow Document Map (nanoCSS Paths)

The global workflows in `~/.agents/workflows/` reference generic document names.
Here is the nanoCSS mapping:

| Workflow expects | nanoCSS equivalent |
|---|---|
| `design/SPRINT-PLAN.md` | `design/SPRINT-PLAN.md` (created alongside this file) |
| `design/BACKLOG.md` | `design/BACKLOG.md` (same name ✅) |
| `design/CHANGELOG.md` | `design/CHANGELOG.md` (same name ✅) |
| `design/DEFINITION-OF-DONE.md` | `design/DEFINITION-OF-DONE.md` (created alongside this file) |
| `design/TEST-PLAN.md` | `design/TEST-PLAN.md` (created alongside this file) |
| `design/SYSTEM-ARCHITECTURE.md` | `design/SYSTEM_DESIGN.md` (note underscore) |
| `design/TECH-STACK.md` | Embedded in `design/PRD.md` §11 (no standalone file) |

---

*For full context: `design/PRD.md` · `design/SYSTEM_DESIGN.md` · `design/BACKLOG.md` · `AGENTS.md`*
