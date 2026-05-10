---
vc-id: d7195294-bd55-49e4-a24e-bd81e794156e
---
# TEST PLAN

> **Project:** nanoCSS
> **Date:** 2026-05-07
> **Status:** 🟢 Active


> **Project:** nanoCSS
> **Purpose:** Defines the testing strategy, spec structure, patterns, and exemplars for every layer.
> Every Use Case's Acceptance Criteria should map to at least one spec in one of the tiers below.

---

## Testing Stack

| Tool | Layer | Notes |
|---|---|---|
| RSpec | Unit + integration | All spec types |
| Capybara + Selenium | System (E2E) | Full browser, JS enabled |
| FactoryBot | Not used — stateless app | Use `ThemeConfiguration.new(...)` directly |
| VCR / WebMock | External HTTP (Google Fonts) | Stub `GoogleFontsService` HTTP calls in unit tests |

**Important:** This app is stateless. There is no database, no fixtures, no factories. Test data is
built via `ThemeConfiguration.new(attrs)` or `ThemeConfiguration.from_base64(token)`.

---

## Spec Directory Layout

```
spec/
├── models/
│   └── theme_configuration_spec.rb   # PORO validation, serialisation, defaults
├── services/
│   ├── scss_compiler_service_spec.rb  # Compilation pipeline, tier/scope/exclusion
│   ├── colour_harmony_service_spec.rb # HSL rotation algorithms
│   ├── google_fonts_service_spec.rb   # Catalogue cache, whitelist guard
│   └── zip_assembler_service_spec.rb  # Archive structure, prefix, minification
├── requests/
│   ├── themes_spec.rb                 # HTTP-level controller specs
│   └── components_spec.rb
└── system/
    ├── preset_quick_apply_spec.rb     # Landing page preset cards + link-swap
    ├── theme_configuration_spec.rb    # Full config form → preview → download
    ├── colour_harmony_spec.rb         # Swatch buttons populate form fields
    └── component_catalogue_spec.rb    # Copy-to-clipboard, test page render
```

---

## Unit Test Patterns

### `ThemeConfiguration`

```ruby
RSpec.describe ThemeConfiguration do
  describe "defaults" do
    subject { described_class.new }
    it { is_expected.to have_attributes(primary: "#1e40af") }   # Corporate default
    it { is_expected.to have_attributes(prefix: "nanocss") }
  end

  describe "validation" do
    it "rejects malformed hex" do
      cfg = described_class.new(primary: "#zzz")
      expect(cfg).not_to be_valid
      expect(cfg.errors[:primary]).to be_present
    end

    it "rejects prefix longer than 32 chars" do
      cfg = described_class.new(prefix: "a" * 33)
      expect(cfg).not_to be_valid
    end
  end

  describe "#to_base64 / .from_base64" do
    it "round-trips all canonical attributes" do
      cfg = described_class.new(primary: "#ff0000", font_code: "JetBrains Mono")
      token = cfg.to_base64
      restored = described_class.from_base64(token)
      expect(restored.primary).to eq "#ff0000"
      expect(restored.font_code).to eq "JetBrains Mono"
    end

    it "falls back to defaults on malformed token" do
      cfg = described_class.from_base64("!!invalid!!")
      expect(cfg.primary).to eq "#1e40af"
    end
  end
end
```

### `ScssCompilerService`

```ruby
RSpec.describe ScssCompilerService do
  let(:cfg) { ThemeConfiguration.new }

  it "returns a CSS string for a valid config" do
    result = described_class.call(cfg)
    expect(result[:error]).to be_nil
    expect(result[:css]).to include("--nanocss-primary")
  end

  it "scopes output when scope: is provided" do
    result = described_class.call(cfg, scope: "#nanocss-preview")
    expect(result[:css]).to include("#nanocss-preview {")
  end

  it "wraps in @layer when wrap_in_layer is true" do
    cfg.wrap_in_layer = true
    result = described_class.call(cfg)
    expect(result[:css]).to match(/@layer/)
  end

  it "omits excluded components" do
    cfg.excluded_components = ["Modal"]
    result = described_class.call(cfg)
    expect(result[:css]).not_to match(/nanocss-modal/)
  end
end
```

### `ColourHarmonyService`

```ruby
RSpec.describe ColourHarmonyService do
  it "returns an array of two hex strings for :complementary" do
    result = described_class.call("#3b82f6", harmony_type: :complementary)
    expect(result).to all(match(/\A#[0-9a-f]{6}\z/i))
    expect(result.length).to eq 2
  end

  it "handles a greyscale primary without raising" do
    expect { described_class.call("#888888", harmony_type: :triadic) }.not_to raise_error
  end
end
```

---

## Request Test Patterns

```ruby
RSpec.describe "Themes", type: :request do
  describe "POST /themes/preview" do
    it "returns a turbo stream replacing the preview link" do
      post themes_preview_path,
           params: { theme_configuration: { primary: "#ff0000", prefix: "myapp" } },
           headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response).to have_http_status(:ok)
      # ADR-003: preview swaps a <link> tag, NOT a <style> tag
      expect(response.body).to include('target="nanocss-preview-link"')
      expect(response.body).to include('/themes/css?theme=')
      expect(response.body).not_to include('<style>')
    end

    it "returns 422 for an invalid hex code" do
      post themes_preview_path,
           params: { theme_configuration: { primary: "#zzz" } },
           headers: { "Accept" => "text/vnd.turbo-stream.html" }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "GET /themes/css" do
    it "serves text/css for a valid token" do
      token = ThemeConfiguration.new.to_base64
      get themes_css_path(theme: token)
      expect(response.content_type).to include("text/css")
    end
  end
end
```

---

## System Test Patterns

```ruby
RSpec.describe "Preset Quick Apply", type: :system do
  before { driven_by :selenium_chrome_headless }

  it "swapping to the Playful preset changes the preview link href" do
    visit root_path
    link_before = find("#nanocss-preview-link")["href"]
    click_button "Apply Playful"
    expect(page).to have_css("#nanocss-preview-link[href*='/themes/css']")
    link_after = find("#nanocss-preview-link")["href"]
    expect(link_after).not_to eq link_before
  end
end
```

---

## Mocking Rules

| What | How |
|---|---|
| `GoogleFontsService` HTTP calls | `allow(Net::HTTP).to receive(:get).and_return(...)` or WebMock stub |
| Clock | `travel_to(Time.zone.local(2026, 4, 25))` |
| Sass compilation | **Never mock** — compilation is the thing being tested |
| File system (SCSS partials) | **Never mock** — they are real files committed to the repo |

---

## Current Test Suite State (Sprint 5 close)

| File | Specs | Status |
|---|---|---|
| `spec/models/theme_configuration_spec.rb` | ~30 | 3 failing — default colour assertions (UC-026) |
| `spec/requests/themes_spec.rb` | ~20 | 1 failing — `<style>` vs `<link>` swap (UC-026 / ADR-003) |
| All others | ~31 | Green |
| **Total** | **~81** | **77 green, 4 failing** |

The 4 failing specs must **not** be `skip`ped or `pending`-ed. UC-026 (Sprint 6) repairs them properly.
