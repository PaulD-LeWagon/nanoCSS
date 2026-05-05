require 'rails_helper'

# Traces: design/BACKLOG.md UC-037
RSpec.describe "Theme Switcher in Application Layout", type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  describe "UC-037: Floating Theme Switcher mounted in application layout" do
    it "AC1: Theme Switcher is present on the landing page" do
      visit root_path
      expect(page).to have_css(".nanocss-theme-switcher", visible: :all)
    end

    it "AC1: Theme Switcher is present on the component catalogue" do
      visit components_path
      expect(page).to have_css(".nanocss-theme-switcher", visible: :all)
    end

    it "AC2: Theme Switcher is suppressed on the configure page" do
      visit configure_path
      expect(page).not_to have_css(".nanocss-theme-switcher", visible: :all)
    end
  end
end
