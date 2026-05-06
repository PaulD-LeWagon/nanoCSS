# nanoCSS Configurator

A stateless Rails app that lets indie developers configure, preview, and download a
custom-namespaced CSS framework — compiled on the fly. No accounts, no database, no lock-in.

---

## What Is nanoCSS?

nanoCSS is a lightweight, fully-prefixed CSS framework. Every selector is namespaced
(e.g. `.myapp-btn-primary`, `.myapp-card`) so it can coexist safely in any host app
without specificity wars.

The Configurator is the SaaS wrapper: pick a preset, adjust colours/fonts/spacing,
preview the result live, then download a ZIP containing your bespoke framework files.

---

## Screenshots

![Landing page — preset cards and hero](docs/screenshots/landing.png)
*Landing page: three preset cards (Corporate, Playful, Minimalist, Obsidian) and a live
hero section that re-skins on Quick Apply.*

![Configure page — live preview](docs/screenshots/configure.png)
*Configure page: colour pickers, Google Fonts selector, harmony swatches, and a live
preview pane that updates via Turbo Streams.*

![Component Catalogue](docs/screenshots/catalogue.png)
*Component Catalogue: all 20 components rendered under the active theme, with
copy-to-clipboard snippets and an IntersectionObserver sidebar.*

> **Note for contributors:** capture these screenshots with `bin/rails server` running at
> the default theme, then commit the images to `docs/screenshots/`.

---

## Hosted App

Try it live: **https://nanocss.example.com** *(replace with production URL when deployed)*

---

## What's in the ZIP

When you click **Download**, you receive a `.zip` archive structured as:

```
{prefix}.css           ← compiled, expanded CSS ready to link
{prefix}.min.css       ← minified via Sass :compressed — production-ready
scss/
  _variables.scss      ← Sass variable definitions ($prefix-primary, etc.)
  _custom-properties.scss  ← CSS custom properties (:root { --prefix-* })
  _reset.scss          ← normalisation base
  _base.scss           ← typography defaults
  _mixins.scss         ← reusable Sass mixins
  _utilities.scss      ← utility classes (.{prefix}-text-muted, etc.)
  _components.scss     ← @use index for all component partials
  components/
    _badges.scss
    _banner.scss
    _breadcrumbs.scss
    _buttons.scss
    _card.scss
    _carousel.scss
    _dark_mode.scss
    _dropdown.scss
    _group.scss
    _hero.scss
    _loading.scss
    _modal.scss
    _nav.scss
    _pagination.scss
    _tabs.scss
    _tags.scss
    _theme_switcher.scss
    _tooltip.scss
```

Drop `{prefix}.css` into your `<head>` — or import the SCSS tree into your own build if
you want partial control. The prefix is yours; no class name will collide with anything
already in your project.

---

## Running Locally

**Requirements:** Ruby 3.3+, Dart Sass (`sass-embedded` gem), Chrome (for system specs)

```bash
git clone https://github.com/PaulD-LeWagon/nanoCSS.git
cd nanoCSS
bundle install
bin/rails server
```

Open http://localhost:3000. No database setup required — the app is fully stateless.

---

## Running the Test Suite

```bash
bundle exec rspec                   # full suite (system specs require Chrome)
bundle exec rspec spec/models       # unit specs only
bundle exec rspec spec/services     # service layer only
bundle exec rspec spec/system       # Selenium / Capybara E2E
bundle exec rubocop                 # style check
bundle exec brakeman --no-pager     # security scan
```

---

## Architecture at a Glance

| Layer | Technology |
|---|---|
| Web framework | Rails 8, Hotwire (Turbo Streams + Stimulus) |
| CSS compilation | Dart Sass (`sass-embedded` gem) in-process |
| Download assembly | rubyzip |
| Models | POROs + `ActiveModel::Model` — no database |
| Tests | RSpec + Selenium/Capybara |

Key source files:

| File | Role |
|---|---|
| `app/models/theme_configuration.rb` | The only "model" — validates, serialises, round-trips via base64 |
| `app/services/scss_compiler_service.rb` | 7-step Dart Sass compilation pipeline |
| `app/services/colour_harmony_service.rb` | HSL rotation for palette suggestions |
| `app/services/google_fonts_service.rb` | Font catalogue cache + whitelist guard |
| `app/controllers/themes_controller.rb` | `preview`, `css`, `download` actions |

---

## Contributing

1. Read `CLAUDE.md` — it contains the hard do-nots and coding conventions.
2. Pick a story from `design/BACKLOG.md` (filter by `⚪ To Do`).
3. Follow the TDD cycle: write specs first, implement to pass, run DoD gates.
4. Conventional Commits: `type(scope): description [UC-NNN]`
