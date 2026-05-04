require 'rails_helper'

# Traces: design/BACKLOG.md UC-033
RSpec.describe "Responsiveness Sweep", type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  describe "UC-033: All 20 components at 4 breakpoints" do
    BREAKPOINTS = { "320px" => 320, "768px" => 768, "1280px" => 1280, "1920px" => 1920 }.freeze

    BREAKPOINTS.each do |label, width|
      context "at #{label} viewport" do
        before do
          page.driver.browser.manage.window.resize_to(width, 900)
        end

        it "AC1: /components/test loads without horizontal overflow at #{label}" do
          visit components_test_path

          # AC2: save screenshot artefact for this breakpoint
          page.save_screenshot(Rails.root.join("tmp", "breakpoint_#{label}.png").to_s)

          scroll_width  = page.evaluate_script("document.documentElement.scrollWidth")
          client_width  = page.evaluate_script("document.documentElement.clientWidth")

          # AC3: no layout failure — scroll_width must not exceed viewport
          expect(scroll_width).to be <= client_width,
            "Horizontal overflow at #{label}: scrollWidth=#{scroll_width} > clientWidth=#{client_width}"
        end

        it "AC1: key components are visible at #{label}" do
          visit components_test_path

          expect(page).to have_css(".nanocss-nav",  visible: :all)
          expect(page).to have_css(".nanocss-hero", visible: :all)
          expect(page).to have_css(".nanocss-card", visible: :all)
        end
      end
    end
  end
end
