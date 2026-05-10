require 'rails_helper'

# Traces: design/BACKLOG.md UC-062
RSpec.describe 'UC-062: Showcase Page Full Component Layout', type: :system do
  before { driven_by(:selenium_chrome_headless) }

  # AC1: Zero custom CSS — no style= attributes in the showcase view
  it 'AC1 (lint): showcase view files contain no style= attributes' do
    showcase_views = Dir.glob(Rails.root.join('app/views/showcase/**/*.erb'))
    expect(showcase_views).not_to be_empty
    showcase_views.each do |file|
      content = File.read(file)
      expect(content).not_to match(/\bstyle\s*=\s*['"]/),
        "#{file} contains a style= attribute — all styling must come from nanoCSS classes"
    end
  end

  # AC2: Left accordion sidebar exists
  it 'AC2: left accordion sidebar is present with anchor links to right-pane sections' do
    visit showcase_path
    expect(page).to have_css('aside .nanocss-accordion', visible: :all)
    # Check a sample of anchor links
    %w[#hero #cards #interactive #theming].each do |anchor|
      expect(page).to have_css("aside a[href='#{anchor}']", visible: :all)
    end
  end

  # AC3: Right pane sections exist in correct order
  it 'AC3: all required right-pane sections are present' do
    visit showcase_path
    %w[hero cards copy carousel interactive labels navigation utilities alerts theming].each do |section_id|
      expect(page).to have_css("section##{section_id}", visible: :all),
        "Expected section##{section_id} to be present"
    end
  end

  # AC4: All 19 components appear at least once
  it 'AC4: all 19 components appear on the showcase page' do
    visit showcase_path
    # Accordion (wrapper)
    expect(page).to have_css('.nanocss-accordion', visible: :all)
    # Badge
    expect(page).to have_css('.nanocss-badge', visible: :all)
    # Banner
    expect(page).to have_css('.nanocss-banner', visible: :all)
    # Breadcrumb
    expect(page).to have_css('.nanocss-breadcrumb', visible: :all)
    # Button
    expect(page).to have_css('.nanocss-btn-primary', visible: :all)
    # Card
    expect(page).to have_css('.nanocss-card', visible: :all)
    # Carousel
    expect(page).to have_css('.nanocss-carousel', visible: :all)
    # Dropdown
    expect(page).to have_css('.nanocss-dropdown', visible: :all)
    # Group
    expect(page).to have_css('.nanocss-group', visible: :all)
    # Hero
    expect(page).to have_css('.nanocss-hero', visible: :all)
    # Loading
    expect(page).to have_css('.nanocss-loader', visible: :all)
    # Modal
    expect(page).to have_css('.nanocss-modal', visible: :all)
    # Nav (the top sticky nav + the nav demo)
    expect(page).to have_css('.nanocss-nav', visible: :all)
    # Pagination
    expect(page).to have_css('.nanocss-pagination', visible: :all)
    # Tabs
    expect(page).to have_css('.nanocss-tabs', visible: :all)
    # Tags
    expect(page).to have_css('.nanocss-tag', visible: :all)
    # Theme Switcher (floating widget from layout)
    expect(page).to have_css('.nanocss-theme-switcher', visible: :all)
    # Tooltip
    expect(page).to have_css('.nanocss-tooltip', visible: :all)
    # Sticky + Glass nav (the showcase header)
    expect(page).to have_css('.nanocss-nav.nanocss-sticky', visible: :all)
  end

  # AC5: Instructional copy — hero headline
  it 'AC5: hero headline contains dogfooded instructional copy' do
    visit showcase_path
    within('#hero') do
      expect(page).to have_content('Build bespoke CSS frameworks in seconds')
    end
  end

  # AC6: theming section contains a visible link back to /configure
  it 'AC6: theming section contains a link to the configure page' do
    visit showcase_path
    within('#theming') do
      expect(page).to have_link(href: configure_path)
      expect(page).to have_css('.nanocss-btn-primary')
    end
  end

  # AC7: responsive — page renders without horizontal scroll at 375px and 1280px
  it 'AC7: renders without horizontal scroll at 375px viewport' do
    page.driver.browser.manage.window.resize_to(375, 812)
    visit showcase_path
    # Page width should not exceed viewport width (no horizontal scroll)
    scroll_width = page.evaluate_script('document.body.scrollWidth')
    client_width  = page.evaluate_script('document.documentElement.clientWidth')
    expect(scroll_width).to be <= client_width + 5  # 5px tolerance
  end

  it 'AC7: renders without horizontal scroll at 1280px viewport' do
    page.driver.browser.manage.window.resize_to(1280, 800)
    visit showcase_path
    scroll_width = page.evaluate_script('document.body.scrollWidth')
    client_width  = page.evaluate_script('document.documentElement.clientWidth')
    expect(scroll_width).to be <= client_width + 5
  end

  # AC8: right-pane sections can be directly linked from left accordion
  it 'AC8: each right-pane section has a corresponding anchor link in the sidebar' do
    visit showcase_path
    %w[hero cards copy carousel interactive labels navigation utilities alerts theming].each do |section_id|
      expect(page).to have_css("aside a[href='##{section_id}']", visible: :all),
        "Expected sidebar anchor link to ##{section_id}"
    end
  end
end
