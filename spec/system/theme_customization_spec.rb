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

      # Capture initial state — the preview should have compiled CSS
      initial_style = find("#nanocss-preview-style style", visible: false).text(:all)

      # Click Playful Quick Apply (Playful uses primary #f43f5e)
      within(first('div.glass-panel', text: 'Playful')) do
        click_on "Quick Apply"
      end

      # Wait for Turbo Stream to replace the style tag
      # The new CSS must contain the Playful preset's custom property value
      expect(page).to have_css(
        "#nanocss-preview-style style",
        visible: false,
        text: /--nanocss-primary:\s*#f43f5e/,
        wait: 5
      )
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
      expect(page).to have_field("Headings Font")
      expect(page).to have_field("Subtitle Font")
      expect(page).to have_field("Body Font")
      expect(page).to have_field("Code Font")

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
      fill_in "Headings Font", with: "Oswald"
      check "Advanced Options"
      fill_in "Namespace Prefix", with: "mypref"
      uncheck "Advanced Options"

      # Headings Font should still contain "Oswald"
      expect(page).to have_field("Headings Font", with: "Oswald")

      # Re-check to verify prefix survived the toggle
      check "Advanced Options"
      expect(page).to have_field("Namespace Prefix", with: "mypref")
    end

    it "AC4: changing an input causes a VISIBLE change in the preview pane" do
      # The preview pane should have compiled CSS initially with custom properties
      expect(page).to have_css("#nanocss-preview-style style", visible: false, text: /--nanocss-primary/)

      # Change the prefix — this changes ALL custom property names across the output
      check "Advanced Options"
      fill_in "Namespace Prefix", with: "livetest"

      # The form auto-submits via oninput -> requestSubmit -> Turbo Stream
      # All custom property names should now use the "livetest" prefix
      expect(page).to have_css(
        "#nanocss-preview-style style",
        visible: false,
        text: /--livetest-primary/,
        wait: 5
      )
    end

    it "AC4: changing a colour input updates the CSS custom property value" do
      # Change the primary colour to bright red
      fill_in "Primary", with: "#ff0000"

      # Wait for Turbo Stream — the compiled CSS should contain the new colour
      expect(page).to have_css(
        "#nanocss-preview-style style",
        visible: false,
        text: /#ff0000/,
        wait: 5
      )
    end
  end

  # --- UC-003: Download Engine ---
  describe "UC-003: Download" do
    it "AC1: clicking Download does not error" do
      visit configure_path
      click_on "Download"
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
        font_heading: "Oswald",
        font_code: "Source Code Pro",
        mode: "advanced",
        base_space: "0.75rem",
        base_margin: "2rem"
      ).to_base64

      visit configure_path(theme: encoded)

      expect(page).to have_field("Primary", with: "#00ff00")
      expect(page).to have_field("Headings Font", with: "Oswald")
      expect(page).to have_field("Code Font", with: "Source Code Pro")
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

      # The compiled CSS should contain the share URL's custom properties
      expect(page).to have_css(
        "#nanocss-preview-style style",
        visible: false,
        text: /--tester-primary:\s*#00ff00/,
        wait: 5
      )
    end
  end
end
