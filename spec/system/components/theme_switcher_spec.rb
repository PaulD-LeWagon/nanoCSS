require 'rails_helper'

# Traces: design/BACKLOG.md UC-022, UC-047, UC-048
RSpec.describe "Floating Theme Switcher", type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  # Force a known initial state regardless of the test machine's OS dark-mode
  # preference. Stimulus connect() sets data-theme from matchMedia, so tests
  # that exercise the toggle must explicitly seed to "light" first.
  def force_light_mode
    page.execute_script("document.documentElement.setAttribute('data-theme','light')")
    page.execute_script("localStorage.setItem('nanocss-theme','light')")
  end

  describe "UC-022: Floating Theme Switcher" do
    it "AC1 & AC2: Floating widget exists and expands via <details>" do
      visit components_test_path

      expect(page).to have_css(".nanocss-theme-switcher")
      expect(page).to have_css(".nanocss-theme-switcher details")
      expect(page).to have_css(".nanocss-theme-switcher svg")
    end

    it "AC3: Toggles dark mode on the html tag", js: true do
      visit components_test_path
      force_light_mode

      find(".nanocss-theme-switcher summary").click
      find("[data-action='click->theme#toggleDark']").click

      expect(page).to have_css("html[data-theme='dark']", visible: :all)

      find("[data-action='click->theme#toggleDark']").click
      expect(page).not_to have_css("html[data-theme='dark']")
    end
  end

  describe "UC-047: Fix Dark Mode Theme-Switcher Regression" do
    it "AC1: toggling back to light sets data-theme='light' explicitly (not removes attribute)" do
      visit components_test_path
      force_light_mode

      find(".nanocss-theme-switcher summary").click

      # Toggle to dark
      find("[data-action='click->theme#toggleDark']").click
      expect(page).to have_css("html[data-theme='dark']", visible: :all)

      # Toggle back to light — must set 'light', NOT remove the attribute
      find("[data-action='click->theme#toggleDark']").click
      expect(page).to have_css("html[data-theme='light']", visible: :all)
      expect(page).not_to have_css("html:not([data-theme])", visible: :all)
    end

    it "AC1: data-theme attribute is always present after connect()" do
      visit components_test_path

      # Regardless of OS preference, Stimulus connect() sets data-theme explicitly
      expect(page).to have_css("html[data-theme]", visible: :all)
    end
  end

  describe "UC-048: Component Catalogue Dark-Mode Contamination" do
    it "AC1: catalogue page has an explicit data-theme after Stimulus initialises" do
      visit components_path

      expect(page).to have_css("html[data-theme]", visible: :all)
    end

    it "AC3: nanocss-card on catalogue does not show dark neutral background when in light mode" do
      visit components_path
      force_light_mode

      card_bg = page.evaluate_script(
        "getComputedStyle(document.querySelector('.nanocss-card')).backgroundColor"
      )
      # Dark neutral-100 = #334155 = rgb(51, 65, 85). Must NOT appear in light mode.
      expect(card_bg).not_to include("51, 65, 85"),
        "Card background is dark (#{card_bg}) — data-theme='light' override failed"
    end
  end
end
