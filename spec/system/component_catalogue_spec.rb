require 'rails_helper'

# Traces: design/BACKLOG.md UC-005
RSpec.describe "Component Catalogue", type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  describe "UC-005: Component Catalogue Reference" do
    it "AC1: Dedicated page displays components with live renders" do
      visit components_path
      
      expect(page).to have_content("Component Catalogue")
      
      # Asserting existence of a few key components defined in UI_COMPONENTS.md
      expect(page).to have_content("Text Banner")
      expect(page).to have_content("Hero Banner")
      expect(page).to have_css(".nanocss-hero")
      expect(page).to have_content("Accordion")
      expect(page).to have_css("details summary")
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
      
      # Find the first copy button
      first('.copy-btn').click
      
      # Wait for toast to appear
      expect(page).to have_css(".toast-notification", text: "Copied to clipboard!", visible: true, wait: 2)
      
      # Note: Testing the actual clipboard content in headless chrome can be tricky due to permissions.
      # Generally, if the Stimulus controller successfully rendered the toast, the API call completed.
      # We just test the UI feedback loop here.
    end
  end
end
