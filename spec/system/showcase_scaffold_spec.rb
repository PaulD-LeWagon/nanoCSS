require 'rails_helper'

# Traces: design/BACKLOG.md UC-061
RSpec.describe 'UC-061: Showcase Page Scaffold', type: :system do
  before { driven_by(:selenium_chrome_headless) }

  # AC6: GET /showcase returns 200; app nav suppressed; showcase nav present
  it 'AC6: GET /showcase returns 200 and suppresses the global app navbar' do
    visit '/showcase'
    expect(page).to have_current_path('/showcase')
    # AC3: The app nav (with root_path brand link) must not be rendered from the layout
    # The app nav contains a brand link pointing to "/" with text "nanoCSS" that navigates home.
    # On the showcase page, @suppress_app_nav = true removes the layout nav entirely;
    # the showcase provides its own nav (AC5).
    expect(page).not_to have_css('.app-container > .nanocss-nav')
    # AC5: showcase provides its own nav
    expect(page).to have_css('.nanocss-nav')
  end

  # AC7: app navbar on GET / contains a link to /showcase
  it 'AC7: app navbar on the landing page contains a Showcase link' do
    visit root_path
    within('nav.nanocss-nav') do
      expect(page).to have_link('Showcase', href: '/showcase')
    end
  end

  # AC5: showcase navbar has wordmark and right-hand links (first .nanocss-nav on page)
  it 'AC5: showcase navbar contains nanoCSS wordmark and nav links' do
    visit '/showcase'
    # The first nanocss-nav on the page is the showcase's own sticky navbar
    within(first('.nanocss-nav')) do
      expect(page).to have_content('nanoCSS')
      expect(page).to have_link('Catalogue')
      expect(page).to have_link('Configure →')
    end
  end
end
