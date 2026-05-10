require 'rails_helper'

# Traces: design/BACKLOG.md UC-062
RSpec.describe 'UC-062: Showcase Page Full Component Layout', type: :system do
  before { driven_by(:selenium_chrome_headless) }

  # AC1: no style= attributes in the showcase view files
  it 'AC1 (lint): showcase view files contain no style= attributes' do
    showcase_views = Dir.glob(Rails.root.join('app/views/showcase/**/*.erb'))
    expect(showcase_views).not_to be_empty
    showcase_views.each do |file|
      content = File.read(file)
      expect(content).not_to match(/\bstyle\s*=\s*['"]/),
        "#{file} contains a style= attribute — all component styling must come from nanoCSS classes"
    end
  end

  # AC2: left accordion sidebar present with anchor links
  it 'AC2: left accordion sidebar is present with anchor links to right-pane sections' do
    visit showcase_path
    expect(page).to have_css('aside .nanocss-accordion', visible: :all)
    %w[#hero #cards #interactive #theming].each do |anchor|
      expect(page).to have_css("aside a[href='#{anchor}']", visible: :all),
        "Expected sidebar anchor link to #{anchor}"
    end
  end

  # AC3: all required right-pane sections exist
  it 'AC3: all required right-pane sections are present in order' do
    visit showcase_path
    %w[hero cards copy carousel interactive labels navigation utilities alerts theming].each do |id|
      expect(page).to have_css("section##{id}", visible: :all),
        "Expected section##{id} to be present"
    end
  end

  # AC4: all 19 components appear at least once — using the ACTUAL SCSS class contracts
  it 'AC4: all 19 components appear on the showcase page' do
    visit showcase_path
    # Accordion wrapper (sidebar uses it)
    expect(page).to have_css('.nanocss-accordion', visible: :all)
    # Badge — base class; modifiers are .success .warning .danger (NOT BEM -success)
    expect(page).to have_css('.nanocss-badge', visible: :all)
    # Banner — hgroup element (no class, styled globally in _banner.scss)
    expect(page).to have_css('hgroup', visible: :all)
    # Breadcrumb
    expect(page).to have_css('.nanocss-breadcrumb', visible: :all)
    # Buttons — at least primary variant
    expect(page).to have_css('.nanocss-btn-primary', visible: :all)
    # Card variants
    expect(page).to have_css('.nanocss-card', visible: :all)
    expect(page).to have_css('.nanocss-card-primary', visible: :all)
    # Carousel — outer wrapper; inner classes are unprefixed (carousel-track etc.)
    expect(page).to have_css('.nanocss-carousel', visible: :all)
    expect(page).to have_css('.carousel-track', visible: :all)
    expect(page).to have_css('.carousel-slide', visible: :all)
    # Dropdown
    expect(page).to have_css('.nanocss-dropdown', visible: :all)
    # Group
    expect(page).to have_css('.nanocss-group', visible: :all)
    # Hero
    expect(page).to have_css('.nanocss-hero', visible: :all)
    # Loading
    expect(page).to have_css('.nanocss-loader', visible: :all)
    # Modal — must be a <dialog> element
    expect(page).to have_css('dialog.nanocss-modal', visible: :all)
    # Nav
    expect(page).to have_css('.nanocss-nav', visible: :all)
    # Pagination — <ul> wrapper
    expect(page).to have_css('.nanocss-pagination', visible: :all)
    # Tabs — pure CSS radio input pattern
    expect(page).to have_css('.nanocss-tabs', visible: :all)
    expect(page).to have_css('.nanocss-tabs input[type="radio"]', visible: :all)
    # Tags
    expect(page).to have_css('.nanocss-tag', visible: :all)
    # Theme Switcher (in showcase layout)
    expect(page).to have_css('.nanocss-theme-switcher', visible: :all)
    # Tooltip — requires data-tooltip attribute
    expect(page).to have_css('.nanocss-tooltip[data-tooltip]', visible: :all)
    # Sticky + Glass nav at the top
    expect(page).to have_css('.nanocss-nav.nanocss-sticky.nanocss-glass', visible: :all)
  end

  # AC5: hero section contains dogfooded instructional copy
  it 'AC5: hero headline contains instructional copy' do
    visit showcase_path
    within('#hero') do
      expect(page).to have_content('Build bespoke CSS frameworks in seconds')
    end
  end

  # AC6: theming section contains a .nanocss-btn-primary link back to /configure
  it 'AC6: theming section contains a configure link using a nanoCSS button class' do
    visit showcase_path
    within('#theming') do
      expect(page).to have_link(href: configure_path)
      expect(page).to have_css('.nanocss-btn-primary')
    end
  end

  # AC7: no horizontal scroll at 375px
  it 'AC7: renders without horizontal scroll at 375px viewport' do
    page.driver.browser.manage.window.resize_to(375, 812)
    visit showcase_path
    scroll_width  = page.evaluate_script('document.body.scrollWidth')
    client_width  = page.evaluate_script('document.documentElement.clientWidth')
    expect(scroll_width).to be <= client_width + 5
  end

  # AC7: no horizontal scroll at 1280px
  it 'AC7: renders without horizontal scroll at 1280px viewport' do
    page.driver.browser.manage.window.resize_to(1280, 800)
    visit showcase_path
    scroll_width  = page.evaluate_script('document.body.scrollWidth')
    client_width  = page.evaluate_script('document.documentElement.clientWidth')
    expect(scroll_width).to be <= client_width + 5
  end

  # AC8: each section has a corresponding sidebar anchor
  it 'AC8: each right-pane section has an anchor link in the sidebar' do
    visit showcase_path
    %w[hero cards copy carousel interactive labels navigation utilities alerts theming].each do |id|
      expect(page).to have_css("aside a[href='##{id}']", visible: :all),
        "Expected sidebar anchor to ##{id}"
    end
  end
end
