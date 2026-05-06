require 'rails_helper'

# Traces: design/BACKLOG.md UC-028
RSpec.describe "Dropdown Inside Navbar", type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  describe "UC-028: Fix Dropdown Inside Navbar" do
    it "AC1: dropdown trigger inside navbar opens the menu" do
      visit components_test_path

      trigger = find(".nanocss-nav .nanocss-dropdown [data-action*='dropdown#toggle']")
      trigger.click

      expect(page).to have_css(".nanocss-nav .nanocss-dropdown.open")
    end

    it "AC1: menu item inside navbar dropdown is clickable without closing the menu first" do
      visit components_test_path

      find(".nanocss-nav .nanocss-dropdown [data-action*='dropdown#toggle']").click
      expect(page).to have_css(".nanocss-nav .nanocss-dropdown.open")

      within(".nanocss-nav .nanocss-dropdown") do
        find("ul li", text: "Software").click
      end

      # Stimulus controller does not auto-close on item click — menu stays open
      expect(page).to have_css(".nanocss-nav .nanocss-dropdown.open")
    end

    it "AC2: clicking outside the dropdown closes it" do
      visit components_test_path

      find(".nanocss-nav .nanocss-dropdown [data-action*='dropdown#toggle']").click
      expect(page).to have_css(".nanocss-nav .nanocss-dropdown.open")

      find("h1", text: "The Responsive Test Layout").click

      expect(page).not_to have_css(".nanocss-nav .nanocss-dropdown.open")
    end

    it "AC3: Esc closes the navbar dropdown" do
      visit components_test_path

      find(".nanocss-nav .nanocss-dropdown [data-action*='dropdown#toggle']").click
      expect(page).to have_css(".nanocss-nav .nanocss-dropdown.open")

      find("body").send_keys(:escape)

      expect(page).not_to have_css(".nanocss-nav .nanocss-dropdown.open")
    end

    it "AC4: system spec exists and targets the dropdown-inside-navbar regression" do
      visit components_test_path
      # The navbar dropdown must be wired with the Stimulus dropdown controller
      expect(page).to have_css(".nanocss-nav .nanocss-dropdown[data-controller='dropdown']",
                               visible: :all)
    end
  end
end
