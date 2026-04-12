require 'rails_helper'

RSpec.describe "Theme Customization", type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  it "allows a user to select a preset and see the preview update" do
    visit root_path
    
    expect(page).to have_content("Corporate")
    expect(page).to have_content("Playful")
    expect(page).to have_content("Minimalist")

    click_on "Playful"
    
    within "#nanocss-preview-style", visible: false do
      expect(page.html).to include('--nanocss-primary')
    end
  end

  it "allows a user to customize colors and download the result" do
    visit root_path
    click_on "Customise" # Navigates to config page if on landing

    fill_in "Primary Colour", with: "#ff0000"
    
    # Wait for Turbo Stream update
    expect(page).to have_css("#nanocss-preview-style", visible: false, text: /#ff0000/)

    click_on "Download"
    
    expect(page.response_headers['Content-Type']).to eq('application/zip')
    expect(page.response_headers['Content-Disposition']).to include('attachment; filename="nanocss.zip"')
  end

  it "reveals granular inputs when Advanced Mode is toggled" do
    visit root_path
    click_on "Customise"

    expect(page).not_to have_field("Margin Base")
    expect(page).not_to have_field("Text Shadow")

    check "Advanced Options"

    expect(page).to have_field("Margin Base")
    expect(page).to have_field("Text Shadow")
    expect(page).to have_field("Namespace Prefix")
  end

  it "auto-populates secondary colours via Harmony Generator" do
    visit root_path
    click_on "Customise"

    fill_in "Primary Colour", with: "#3b82f6"
    
    # Assuming Harmony Swatches are rendered as clickable elements #harmony-complementary etc
    click_on "Complementary"

    # Expect secondary and tertiary fields to be updated
    expect(page).to have_field("Secondary Colour", with: "#f6af3b") # Placeholder harmony value
  end

  it "handles shareable theme URLs comprehensively" do
    encoded_theme = ThemeConfiguration.new(
      primary: "#00ff00",
      prefix: "tester",
      font_heading: "Oswald",
      space_md: "12px",
      mode: "advanced"
    ).to_base64
    
    visit root_path(theme: encoded_theme)
    
    expect(page).to have_field("Primary Colour", with: "#00ff00")
    expect(page).to have_field("Namespace Prefix", with: "tester")
    expect(page).to have_field("Headings Font", with: "Oswald")
    
    # Needs advanced mode exposed to see space_md
    check "Advanced Options"
    expect(page).to have_field("Spacing Base", with: "12px")
  end
end
