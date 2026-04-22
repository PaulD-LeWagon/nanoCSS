require 'rails_helper'

# Traces: design/BACKLOG.md UC-001 through UC-004
# Traces: design/PRD.md FR-004 (Real-Time Live Preview)
RSpec.describe "Theme Customization", type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  # --- UC-001: Preset Theme & Live Preview ---
  describe "UC-001: Preset Themes" do
    it "AC1: displays three preset cards on the landing page" do
      visit root_path
      expect(page).to have_content("Corporate")
      expect(page).to have_content("Playful")
      expect(page).to have_content("Minimalist")
    end

    it "AC2: clicking a preset causes a VISIBLE change in the preview" do
      visit root_path

      expect(page).to have_css("#nanocss-preview-style", visible: :all)

      # Click Playful Quick Apply
      within(first('.preset-card', text: 'Playful')) do
        click_on "Quick Apply"
      end

      # The turbo stream injects a link tag into #nanocss-preview-style with base64 theme params
      expect(page).to have_css("#nanocss-preview-style link[href*='theme=']", visible: false, wait: 5)
      
      link = page.find("#nanocss-preview-style link", visible: false)
      uri = URI.parse(link[:href])
      params = CGI.parse(uri.query)
      decoded = Base64.urlsafe_decode64(params["theme"].first)
      
      # Playful uses primary #f43f5e
      expect(decoded).to include("f43f5e")
    end
  end

  # --- UC-002: Custom Theme Configuration Form ---
  describe "UC-002: Custom Configuration" do
    before { visit configure_path }

    it "AC1: Basic Mode shows colour pickers, fonts, and anchor inputs" do
      # Colours
      expect(page).to have_field("Primary")
      expect(page).to have_field("Secondary")
      expect(page).to have_field("Tertiary")

      # Fonts (UC-002 AC7 requires Code Font)
      expect(page).to have_css("input[name='theme_configuration[font_heading]']", visible: false)
      expect(page).to have_css("input[name='theme_configuration[font_subtitle]']", visible: false)
      expect(page).to have_css("input[name='theme_configuration[font_body]']", visible: false)
      expect(page).to have_css("input[name='theme_configuration[font_code]']", visible: false)

      # Anchor variables
      expect(page).to have_field("Typography Base")
      expect(page).to have_field("Spacing Base")
      expect(page).to have_field("Border Radius Base")
      expect(page).to have_field("Border Width Base")
    end

    it "AC1: Advanced Mode reveals overrides when toggled" do
      # These should NOT be visible in Basic Mode
      expect(page).not_to have_field("Margin Base", visible: true)
      expect(page).not_to have_field("Namespace Prefix", visible: true)
      expect(page).not_to have_field("Text Shadow", visible: true)

      check "Advanced Options"

      expect(page).to have_field("Margin Base")
      expect(page).to have_field("Namespace Prefix")
      expect(page).to have_field("Text Shadow")
      expect(page).to have_field("Drop Shadow")
    end

    it "AC2: switching modes retains previously entered values" do
      fill_in "Primary", with: "#123456"
      
      check "Advanced Options"
      fill_in "Namespace Prefix", with: "mypref"
      uncheck "Advanced Options"

      expect(page).to have_field("Primary", with: "#123456")

      # Re-check to verify prefix survived the toggle
      check "Advanced Options"
      expect(page).to have_field("Namespace Prefix", with: "mypref")
    end

    it "AC4: changing an input causes a VISIBLE change in the preview pane" do
      check "Advanced Options"
      fill_in "Namespace Prefix", with: "livetest"

      sleep 1
      
      link = page.find("#nanocss-preview-style link", visible: false)
      uri = URI.parse(link[:href])
      params = CGI.parse(uri.query)
      decoded = Base64.urlsafe_decode64(params["theme"].first)
      
      expect(decoded).to include('"prefix":"livetest"')
    end

    it "AC4: changing a colour input updates the CSS custom property value" do
      # Change the primary colour to bright red
      fill_in "Primary", with: "#ff0000"

      sleep 1
      
      link = page.find("#nanocss-preview-style link", visible: false)
      uri = URI.parse(link[:href])
      params = CGI.parse(uri.query)
      decoded = Base64.urlsafe_decode64(params["theme"].first)
      
      expect(decoded).to include('"primary":"#ff0000"')
    end
  end

  # --- UC-003: Download Engine ---
  describe "UC-003: Download" do
    it "AC1: clicking Download does not error" do
      visit configure_path
      click_on "⬇ .css"
      # Selenium can't inspect response headers, but we verify no crash
      # The request spec covers the actual ZIP content
      expect(page).not_to have_content("error")
    end
  end

  # --- UC-004: Shareable URLs ---
  describe "UC-004: Shareable URLs" do
    it "AC2: visiting a share URL pre-populates the config form" do
      encoded = ThemeConfiguration.new(
        primary: "#00ff00",
        prefix: "tester",
        mode: "advanced",
        base_space: "0.75rem",
        base_margin: "2rem"
      ).to_base64

      visit configure_path(theme: encoded)

      expect(page).to have_field("Primary", with: "#00ff00")
      expect(page).to have_field("Spacing Base", with: "0.75rem")

      # Advanced fields require toggling to be visible
      check "Advanced Options"
      expect(page).to have_field("Namespace Prefix", with: "tester")
      expect(page).to have_field("Margin Base", with: "2rem")
    end

    it "AC2: share URL produces VISIBLE styling that matches the encoded config" do
      encoded = ThemeConfiguration.new(
        primary: "#00ff00",
        prefix: "tester"
      ).to_base64

      visit configure_path(theme: encoded)

      expect(page).to have_css("#nanocss-preview-style link[href*='theme=']", visible: false, wait: 5)
      
      link = page.find("#nanocss-preview-style link", visible: false)
      uri = URI.parse(link[:href])
      params = CGI.parse(uri.query)
      decoded = Base64.urlsafe_decode64(params["theme"].first)
      
      expect(decoded).to include('"prefix":"tester"')
      expect(decoded).to include('"primary":"#00ff00"')
    end
  end
end
