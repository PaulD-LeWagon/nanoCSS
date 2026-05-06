require 'rails_helper'

# Traces: design/BACKLOG.md UC-036
RSpec.describe "Chrome uses nanoCSS components", type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  describe "UC-036 AC1: top nav replaced with nanocss-nav component" do
    it "nav uses nanocss-nav class on the landing page" do
      visit root_path
      expect(page).to have_css("nav.nanocss-nav")
    end

    it "nav uses nanocss-nav class on the component catalogue" do
      visit components_path
      expect(page).to have_css("nav.nanocss-nav")
    end

    it "nav uses nanocss-nav class on the configure page" do
      visit configure_path
      expect(page).to have_css("nav.nanocss-nav")
    end

    it "brand link is inside the nanocss-nav" do
      visit root_path
      within("nav.nanocss-nav") do
        expect(page).to have_link("nanoCSS", href: root_path)
      end
    end

    it "Component Catalogue link is inside the nanocss-nav" do
      visit root_path
      within("nav.nanocss-nav") do
        expect(page).to have_link("Component Catalogue")
      end
    end

    it "does not use the old .top-nav class" do
      visit root_path
      expect(page).not_to have_css("nav.top-nav")
    end
  end
end
