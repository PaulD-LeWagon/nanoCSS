require 'rails_helper'

# Traces: design/BACKLOG.md UC-035
RSpec.describe "Quick Apply re-skins the app chrome", type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  describe "UC-035 AC1/AC2: Quick Apply updates the global nanocss framework CSS" do
    it "clicking Quick Apply on landing page updates #nanocss-framework-style" do
      visit root_path

      initial_css = find("style#nanocss-framework-style", visible: :all).text(normalize_ws: false)

      playful_card = find(".preset-card", text: "Playful")
      within(playful_card) { click_button "Quick Apply" }

      expect(page).to have_css(
        "style#nanocss-framework-style",
        visible: :all,
        text: /f43f5e/i
      )
    end

    it "AC2/AC3: nanocss CSS after Quick Apply uses the preset primary colour" do
      visit root_path

      playful_card = find(".preset-card", text: "Playful")
      within(playful_card) { click_button "Quick Apply" }

      # The framework style tag should now contain the Playful primary
      expect(page).to have_css("style#nanocss-framework-style", visible: :all, text: /f43f5e/i)
    end
  end
end
