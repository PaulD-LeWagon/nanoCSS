require 'rails_helper'

# Traces: design/BACKLOG.md UC-029
RSpec.describe "Mobile Navbar", type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  describe "UC-029: Mobile Navbar with Hamburger Toggle" do
    context "at 375px viewport (mobile)" do
      before do
        page.driver.browser.manage.window.resize_to(375, 812)
      end

      it "AC1: hamburger toggle is visible and nav menu is collapsed" do
        visit components_test_path

        expect(page).to have_css("[data-navbar-target='toggle']", visible: true)
        expect(page).not_to have_css("[data-navbar-target='menu']", visible: true)
      end

      it "AC1: clicking hamburger expands the nav menu" do
        visit components_test_path

        find("[data-action='click->navbar#toggle']").click

        expect(page).to have_css("[data-navbar-target='menu'].open", visible: true)
      end

      it "AC2: Esc closes the expanded mobile menu" do
        visit components_test_path

        find("[data-action='click->navbar#toggle']").click
        expect(page).to have_css("[data-navbar-target='menu'].open")

        find("body").send_keys(:escape)

        expect(page).not_to have_css("[data-navbar-target='menu'].open")
      end

      it "AC3: no horizontal scroll at 320px viewport width" do
        page.driver.browser.manage.window.resize_to(320, 568)
        visit components_test_path

        scroll_width  = page.evaluate_script("document.documentElement.scrollWidth")
        client_width  = page.evaluate_script("document.documentElement.clientWidth")

        expect(scroll_width).to be <= client_width
      end
    end

    context "at 1280px viewport (desktop)" do
      before do
        page.driver.browser.manage.window.resize_to(1280, 800)
      end

      it "AC4: hamburger is hidden and nav menu is visible" do
        visit components_test_path

        expect(page).not_to have_css("[data-navbar-target='toggle']", visible: true)
        expect(page).to have_css("[data-navbar-target='menu']", visible: true)
      end
    end
  end
end
