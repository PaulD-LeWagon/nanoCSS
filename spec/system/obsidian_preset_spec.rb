require 'rails_helper'

# Traces: design/BACKLOG.md UC-046
RSpec.describe "Obsidian Preset", type: :system do
  before do
    driven_by(:selenium_chrome_headless)
    allow(GoogleFontsService).to receive(:catalogue)
      .and_return(%w[Inter Roboto Oswald Fira\ Code Source\ Code\ Pro JetBrains\ Mono Merriweather])
  end

  describe "UC-046: Obsidian Preset Card and Quick Apply" do
    it "AC5: Obsidian preset card renders on the landing page" do
      visit root_path
      expect(page).to have_content("Obsidian")
      expect(page).to have_css(".preset-card", text: /Obsidian/i)
    end

    it "AC5: Obsidian Quick Apply fires a Turbo Stream preview update" do
      visit root_path

      within(find(".preset-card", text: /Obsidian/i)) do
        click_on "Quick Apply"
      end

      expect(page).to have_css("#nanocss-preview-style link[href*='theme=']",
                               visible: false, wait: 5)
    end

    it "AC10: Obsidian Quick Apply encodes the Obsidian primary colour in the preview link" do
      visit root_path

      within(find(".preset-card", text: /Obsidian/i)) do
        click_on "Quick Apply"
      end

      expect(page).to have_css("#nanocss-preview-style link", visible: false, wait: 5)
      link = page.find("#nanocss-preview-style link", visible: false)
      uri = URI.parse(link[:href])
      params = CGI.parse(uri.query)
      decoded = Base64.urlsafe_decode64(params["theme"].first)

      # Obsidian primary is #a855f7 (purple)
      expect(decoded).to include("a855f7")
    end
  end

  describe "UC-046: Glass-surface tokens in ThemeConfiguration" do
    it "AC1: ThemeConfiguration accepts surface_blur, surface_opacity, border_glow_alpha" do
      config = ThemeConfiguration.new(
        surface_blur: "12px",
        surface_opacity: "0.85",
        border_glow_alpha: "0.25"
      )
      expect(config.surface_blur).to eq("12px")
      expect(config.surface_opacity).to eq("0.85")
      expect(config.border_glow_alpha).to eq("0.25")
    end

    it "AC2: to_scss_variables_string emits the three glass-surface SCSS variables" do
      config = ThemeConfiguration.new(
        surface_blur: "12px",
        surface_opacity: "0.85",
        border_glow_alpha: "0.25"
      )
      scss = config.to_scss_variables_string
      expect(scss).to include("$nanocss-surface-blur: 12px;")
      expect(scss).to include("$nanocss-surface-opacity: 0.85;")
      expect(scss).to include("$nanocss-border-glow-alpha: 0.25;")
    end

    it "AC3: base64 round-trip preserves glass-surface tokens" do
      config = ThemeConfiguration.new(surface_blur: "12px", surface_opacity: "0.85",
                                      border_glow_alpha: "0.25")
      encoded = config.to_base64
      restored = ThemeConfiguration.from_base64(encoded)
      expect(restored.surface_blur).to eq("12px")
      expect(restored.surface_opacity).to eq("0.85")
      expect(restored.border_glow_alpha).to eq("0.25")
    end

    it "AC3: from_base64 defaults gracefully when glass tokens absent" do
      # Encode a config without the new tokens (e.g. old share link)
      old_config = ThemeConfiguration.new(primary: "#ff0000")
      encoded = old_config.to_base64
      restored = ThemeConfiguration.from_base64(encoded)
      # New tokens should fall back to defaults, not raise
      expect(restored.surface_blur).to eq("0px")
      expect(restored.surface_opacity).to eq("1")
      expect(restored.border_glow_alpha).to eq("0")
    end

    it "AC6+AC8: compiled CSS contains backdrop-filter using surface-blur variable" do
      config = ThemeConfiguration.new(surface_blur: "12px", surface_opacity: "0.85",
                                      border_glow_alpha: "0.25")
      result = ScssCompilerService.call(config)
      expect(result[:css]).to include("backdrop-filter")
      expect(result[:css]).to include("surface-blur")
    end

    it "AC6: compiled CSS hero uses a gradient with primary/secondary CSS vars" do
      result = ScssCompilerService.call(ThemeConfiguration.new)
      expect(result[:css]).to match(/nanocss-hero.*gradient|gradient.*nanocss-hero/m)
    end
  end
end
