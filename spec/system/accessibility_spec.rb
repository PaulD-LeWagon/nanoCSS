require "rails_helper"
require "axe-rspec"

# Traces: design/BACKLOG.md UC-045
# AC1: axe-core run against every page of the configurator and /components/test
RSpec.describe "Accessibility Audit (WCAG 2.1 AA)", type: :system do
  before { driven_by(:selenium_chrome_headless) }

  describe "AC1: every configurator page passes WCAG 2.1 AA" do
    it "landing page (/) is axe-clean" do
      visit root_path
      expect(page).to be_axe_clean.according_to(:wcag21aa)
    end

    it "configure page (/configure) is axe-clean" do
      visit configure_path
      expect(page).to be_axe_clean.according_to(:wcag21aa)
    end

    it "component catalogue (/components) is axe-clean" do
      visit components_path
      expect(page).to be_axe_clean.according_to(:wcag21aa)
    end

    it "component test page (/components/test) is axe-clean" do
      visit components_test_path
      expect(page).to be_axe_clean.according_to(:wcag21aa)
    end
  end
end
