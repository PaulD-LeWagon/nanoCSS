require 'rails_helper'

# Traces: design/BACKLOG.md UC-022
RSpec.describe "Floating Theme Switcher", type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  describe "UC-022: Floating Theme Switcher" do
    it "AC1 & AC2: Floating widget exists and expands via <details>" do
      visit components_test_path
      
      expect(page).to have_css(".nanocss-theme-switcher")
      expect(page).to have_css(".nanocss-theme-switcher details")
      
      # Should contain sun/moon icons (using SVG tag check)
      expect(page).to have_css(".nanocss-theme-switcher svg")
    end

    it "AC3: Toggles dark mode on the html tag", js: true do
      visit components_test_path
      
      # Initial state: should not have dark theme
      expect(page).not_to have_css("html[data-theme='dark']")
      
      # Open the switcher
      find(".nanocss-theme-switcher summary").click
      
      # Click the dark mode toggle (assuming we'll use a button or checkbox)
      find("[data-action='click->theme#toggleDark']").click
      
      # Should now have dark theme
      expect(page).to have_css("html[data-theme='dark']", visible: :all)
      
      # Click again to toggle back
      find("[data-action='click->theme#toggleDark']").click
      expect(page).not_to have_css("html[data-theme='dark']")
    end
  end
end
