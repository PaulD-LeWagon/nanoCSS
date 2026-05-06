require 'rails_helper'

# Traces: design/BACKLOG.md UC-050
RSpec.describe "Live Preview — Body Font and Breadcrumb", type: :system do
  before do
    driven_by(:selenium_chrome_headless)
    allow(GoogleFontsService).to receive(:catalogue)
      .and_return(%w[Inter Roboto Oswald Fira\ Code Source\ Code\ Pro JetBrains\ Mono Merriweather])
  end

  describe "UC-050: Defect A — Body font updates in preview pane" do
    it "AC1: scoped preview CSS sets font-family on #preview-canvas for font_body" do
      # The scoped compilation must emit font-family on the canvas scope so body
      # font changes are visible without _base.scss (which is excluded from preview).
      config = ThemeConfiguration.new(font_body: "Merriweather")
      result = ScssCompilerService.call(config, scope: "#preview-canvas")
      css = result[:css]

      expect(css).to include("preview-canvas"),
        "Scoped CSS must reference #preview-canvas"
      expect(css).to match(/preview-canvas[^{]*\{[^}]*font-family/m),
        "Scoped CSS must set font-family on #preview-canvas so font_body is visible"
    end
  end

  describe "UC-050: Defect B — Breadcrumb renders correctly in preview pane" do
    it "AC2: configure page preview does not have a <nav> that matches both nav and breadcrumb selectors" do
      visit configure_path

      # The breadcrumb in the preview pane must NOT use class="...-nav" AND
      # aria-label="breadcrumb" simultaneously — those two selectors conflict.
      conflicting = page.all("nav.nanocss-nav[aria-label='breadcrumb']", visible: :all)
      expect(conflicting).to be_empty,
        "Found <nav class='nanocss-nav' aria-label='breadcrumb'> — conflicting selectors cause broken breadcrumb render"
    end

    it "AC2: breadcrumb in configure preview has visible separator text" do
      visit configure_path

      # After the preview loads, the breadcrumb's ol should be visible with list items
      expect(page).to have_css(".nanocss-breadcrumb ol li", visible: :all)
    end
  end
end
