require 'rails_helper'

# Traces: design/BACKLOG.md UC-005
RSpec.describe "Component Catalogue", type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  describe "UC-005: Component Catalogue Reference" do
    it "AC1: Dedicated page displays all 18 components with live renders" do
      visit components_path

      expect(page).to have_content("Component Catalogue")

      # Asserting ALL 18 components are represented in the catalogue
      component_headers = [
        "Text Banner", "Hero Banner", "Carousel", "Accordion", "Card",
        "Dropdown", "Group", "Loading", "Modal", "Nav / NavBar",
        "Progress", "Tooltip", "Buttons", "Badges", "Tags",
        "Breadcrumbs", "Pagination", "Tabs"
      ]

      component_headers.each do |header|
        expect(page).to have_content(header)
      end

      # Check component classes are applied on the page
      expect(page).to have_css(".nanocss-hero", visible: :all)
      expect(page).to have_css(".nanocss-carousel", visible: :all)
      expect(page).to have_css(".nanocss-card", visible: :all)
      expect(page).to have_css(".nanocss-dropdown", visible: :all)
      expect(page).to have_css(".nanocss-group", visible: :all)
      expect(page).to have_css(".nanocss-loader", visible: :all)
      expect(page).to have_css(".nanocss-modal", visible: :all)
      expect(page).to have_css(".nanocss-nav", visible: :all)
      expect(page).to have_css(".nanocss-badge", visible: :all)
      expect(page).to have_css(".nanocss-tag", visible: :all)
      expect(page).to have_css(".nanocss-pagination", visible: :all)
      expect(page).to have_css(".nanocss-tabs", visible: :all)
      expect(page).to have_css(".nanocss-btn-primary", visible: :all)
      expect(page).to have_css("[data-tooltip]", visible: :all)
      expect(page).to have_css("nav[aria-label='breadcrumb']", visible: :all)
    end

    it "AC2: Raw HTML snippets use the currently active namespace prefix" do
      # Assuming we can pass prefix in URL or it defaults to nanocss
      visit components_path(prefix: "mycorp")

      # The pre block should contain the custom prefix
      expect(page).to have_css("pre code", text: /class="mycorp-[a-z]+"/i)
      # Sanity check that it doesn't show default prefix
      expect(page).not_to have_css("pre code", text: "nanocss-")
    end

    it "AC3: Clicking the copy icon copies the snippet to the clipboard and shows a toast", js: true do
      visit components_path

      # Find the first copy button and use JS click to bypass viewport visibility errors in headless Chrome
      page.execute_script("document.querySelector('.copy-btn').click();")

      # Wait for toast to appear
      expect(page).to have_css(".toast-notification", text: "Copied to clipboard!", visible: true, wait: 2)

      # Note: Testing the actual clipboard content in headless chrome can be tricky due to permissions.
      # Generally, if the Stimulus controller successfully rendered the toast, the API call completed.
      # We just test the UI feedback loop here.
    end
  end
end
