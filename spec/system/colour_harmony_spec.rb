require 'rails_helper'

# Traces: design/BACKLOG.md UC-006 AC2
RSpec.describe "Colour Harmony UI", type: :system do
  before do
    driven_by(:selenium_chrome_headless)
    # Prevent live Google Fonts API calls during system tests — validators
    # run on every form submission now that the validation gate is wired (UC-023).
    allow(GoogleFontsService).to receive(:catalogue)
      .and_return(%w[Inter Roboto Oswald Fira\ Code Source\ Code\ Pro JetBrains\ Mono Merriweather])
  end

  describe "UC-006: Colour Harmony Generator" do
    it "AC1: Entering a Primary hex reveals suggestion buttons via Turbo" do
      visit configure_path

      # Initially, harmony section should be shown with standard complementary suggestions
      # The harmony buttons are rendered with class harmony-swatch-btn
      expect(page).to have_css(".harmony-swatch-btn")

      # Fill primary to trigger turbo request for new harmonies
      fill_in "Primary", with: "#ff0000"

      # Wait for Turbo Stream to render the harmony options
      expect(page).to have_css(".harmony-swatch-btn", wait: 5)
    end

    it "AC2: Clicking a suggestion populates the Secondary and Tertiary inputs", js: true do
      visit configure_path

      fill_in "Primary", with: "#ff0000"

      # Wait for Turbo Stream to return the new harmony calculation for #ff0000
      expect(page).to have_selector(".swatch-box[style='background:#ff8000;']", wait: 5)

      click_button "Analogous"

      # Secondary and tertiary should now contain the new hexes
      expect(find_field("Secondary").value).to eq("#ff8000")
      expect(find_field("Tertiary").value).to eq("#ff0080")
    end
  end
end
