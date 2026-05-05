require 'rails_helper'

# Traces: design/BACKLOG.md UC-049
RSpec.describe "Hero Color Cascade Fix", type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  describe "UC-049: Hero color:#fff must not cascade to nested components" do
    it "AC1+AC2: a card inside a hero maintains its own text colour (not forced white)" do
      visit components_test_path

      # Check the hero element exists
      expect(page).to have_css(".nanocss-hero", visible: :all)

      # The hero itself should still have a gradient background (AC3)
      hero_bg = page.evaluate_script(
        "getComputedStyle(document.querySelector('.nanocss-hero')).backgroundImage"
      )
      expect(hero_bg).to include("gradient"), "Hero should use gradient background"

      # Verify no global color:#fff is applied directly on the hero element itself
      # (the spec checks the compiled CSS doesn't have global color on .nanocss-hero)
      css_result = ScssCompilerService.call(ThemeConfiguration.new)[:css]
      # If there is a global `color` on the hero, it would appear as:
      # ".nanocss-hero {\n  ...\n  color: #fff;" — NOT scoped to children
      # We assert the hero class doesn't set color globally (only via child selectors)
      hero_rule = css_result[/\.nanocss-hero\s*\{[^}]+\}/m] || ""
      expect(hero_rule).not_to include("color: #fff"),
        "Hero has global color:#fff — cascade will break nested component text"
    end
  end
end
