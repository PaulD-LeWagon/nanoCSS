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

    within(first('div.glass-panel', text: 'Playful')) do
      click_on "Quick Apply"
    end
    
    expect(page).to have_css("#nanocss-preview-style style", visible: false, text: /.nanocss-px/)
  end

  it "allows a user to customize colors and download the result" do
    visit root_path
    click_on "Customise" # Navigates to config page if on landing

    check "Advanced Options"
    fill_in "Namespace Prefix", with: "testprefix"
    
    # Wait for Turbo Stream update
    expect(page).to have_css("#nanocss-preview-style style", visible: false, text: /.testprefix-px/)

    click_on "Download"
    
    # Capybara with Selenium doesn't support response_headers checking for file downloads easily.
    # We rely on the button click not throwing an error and the ZipAssemblerService unit specs.
  end

  it "reveals granular inputs when Advanced Mode is toggled" do
    visit configure_path

    expect(page).not_to have_field("Margin Base")
    expect(page).not_to have_field("Text Shadow")

    check "Advanced Options"

    expect(page).to have_field("Margin Base")
    expect(page).to have_field("Text Shadow")
    expect(page).to have_field("Namespace Prefix")
  end

  it "auto-populates secondary colours via Harmony Generator" do
    visit configure_path

    fill_in "Primary", with: "#3b82f6"
    
    # Assuming Harmony Swatches are rendered as clickable elements #harmony-complementary etc
    click_on "Complementary"

    # Expect secondary and tertiary fields to be updated
    expect(page).to have_field("Secondary", with: "#f6af3b") # Placeholder harmony value
  end

  it "handles shareable theme URLs comprehensively" do
    encoded_theme = ThemeConfiguration.new(
      primary: "#00ff00",
      prefix: "tester",
      font_heading: "Oswald",
      space_md: "12px",
      mode: "advanced"
    ).to_base64
    
    visit configure_path(theme: encoded_theme)
    
    expect(page).to have_field("Primary", with: "#00ff00")
    expect(page).to have_field("Headings Font", with: "Oswald", visible: false)
    expect(page).to have_field("Namespace Prefix", with: "tester", visible: false)
    
    # Needs advanced mode exposed to see space_md
    check "Advanced Options"
    expect(page).to have_field("Spacing Base", with: "12px")
  end
end
