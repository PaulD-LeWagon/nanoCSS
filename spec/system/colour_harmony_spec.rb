require 'rails_helper'

# Traces: design/BACKLOG.md UC-006 AC2
RSpec.describe "Colour Harmony UI", type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  describe "UC-006: Colour Harmony Generator" do
    it "AC1: Entering a Primary hex reveals suggestion buttons via Turbo" do
      visit configure_path
      
      # Initially, harmony section should be shown with standard complementary suggestions
      expect(page).to have_css(".harmony-swatch")
      
      # Fill primary to trigger turbo request for new harmonies
      fill_in "Primary", with: "#ff0000"
      
      # Wait for Turbo Stream to render the complementary colour #00ffff swatch
      expect(page).to have_css(".harmony-swatch[data-color='#00ffff']", visible: true, wait: 5)
    end

    it "AC2: Clicking a suggestion populates the Secondary and Tertiary inputs", js: true do
      visit configure_path
      
      fill_in "Primary", with: "#ff0000"
      
      # Click on an analogous swatch button which holds [secondary, tertiary] data
      # Assuming it renders an Analogous button
      click_button "Analogous"
      
      # Secondary and tertiary should now contain the new hexes
      expect(find_field("Secondary").value).to eq("#ff8000")
      expect(find_field("Tertiary").value).to eq("#ff0080")
    end
  end
end
