require 'rails_helper'

# Traces: design/BACKLOG.md UC-030
RSpec.describe "Prefixed Breadcrumb and Tooltip Selectors", type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  describe "UC-030: Prefix Breadcrumb & Tooltip Components" do
    it "AC1: breadcrumb uses the prefixed class selector" do
      visit components_path

      expect(page).to have_css(".nanocss-breadcrumb", visible: :all)
      # Backward compat: aria-label is preserved for accessibility
      expect(page).to have_css("nav[aria-label='breadcrumb']", visible: :all)
    end

    it "AC2: tooltip uses the prefixed class selector" do
      visit components_path

      expect(page).to have_css(".nanocss-tooltip", visible: :all)
    end

    it "AC3: catalogue snippet for breadcrumb uses the prefixed class" do
      visit components_path(prefix: "mycorp")

      breadcrumb_section = find("section", text: /Breadcrumbs/i)
      expect(breadcrumb_section).to have_css("pre code", text: /class="mycorp-breadcrumb"/)
    end

    it "AC3: catalogue snippet for tooltip uses the prefixed class" do
      visit components_path(prefix: "mycorp")

      tooltip_section = find("section", text: /Tooltip/i)
      expect(tooltip_section).to have_css("pre code", text: /class="mycorp-tooltip"/)
    end
  end
end
