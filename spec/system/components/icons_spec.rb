require 'rails_helper'

# Traces: design/BACKLOG.md UC-021
RSpec.describe "Default Icon Set", type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  describe "UC-021: Default Icon Set" do
    it "AC3: Dedicated page displays all icons with live renders" do
      visit components_path
      
      expect(page).to have_content("Icons")
      
      # Asserting specific icons are present in the catalogue
      # These are the ones mentioned in the plan
      expected_icons = [
        "menu", "close", "chevron-up", "chevron-down", "sun", "moon", "search"
      ]

      expected_icons.each do |icon|
        # We expect to see the name and an SVG
        expect(page).to have_css(".icon-item", text: icon)
        expect(page).to have_css(".icon-item svg")
      end
    end
  end
end
