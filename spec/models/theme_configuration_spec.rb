require 'rails_helper'

RSpec.describe ThemeConfiguration, type: :model do
  describe 'validations' do
    it 'is valid with valid hex codes' do
      config = ThemeConfiguration.new(primary: '#3b82f6', secondary: '#8b5cf6', tertiary: '#ec4899')
      expect(config).to be_valid
    end

    it 'is invalid with an invalid hex code' do
      config = ThemeConfiguration.new(primary: 'invalid')
      expect(config).not_to be_valid
      expect(config.errors[:primary]).to include('is invalid')
    end

    it 'is valid with a valid prefix' do
      config = ThemeConfiguration.new(prefix: 'my-theme-123')
      expect(config).to be_valid
    end

    it 'is invalid with an invalid prefix' do
      config = ThemeConfiguration.new(prefix: 'Invalid Prefix!')
      expect(config).not_to be_valid
      expect(config.errors[:prefix]).to include('is invalid')
    end

    it 'validates font selections against allowed lists (Google Fonts placeholder)' do
      # For now, it should allow standard fonts
      config = ThemeConfiguration.new(font_heading: 'Inter')
      expect(config).to be_valid
    end

    it 'validates text_shadow and drop_shadow matrices format' do
      config = ThemeConfiguration.new(text_shadow: '0.25rem 0.25rem 0.5rem rgba(5,5,5,0.5)')
      expect(config).to be_valid
    end
  end

  describe '#to_scss_variables_string' do
    it 'returns a string of SCSS variable declarations' do
      config = ThemeConfiguration.new(
        primary: '#3b82f6',
        prefix: 'nanocss',
        base_space: '0.5rem',
        base_margin: '1.25rem'
      )
      scss = config.to_scss_variables_string
      expect(scss).to include('$nanocss-primary: #3b82f6;')
      expect(scss).to include('$nanocss-base-space: 0.5rem;')
    end

    it 'decouples padding and margin mathematically if advanced mode overrides them' do
      # If basic mode is used, margin defaults to base_margin
      # If advanced mode overrides margin_md, to_scss_variables_string should map it
      config = ThemeConfiguration.new(
        prefix: 'nanocss',
        mode: 'advanced',
        margin_md: '20px',
        space_md: '10px'
      )
      scss = config.to_scss_variables_string
      expect(scss).to include('$nanocss-margin-md: 20px;')
      expect(scss).to include('$nanocss-space-md: 10px;')
    end
    
    it 'includes the 4 typography slots' do
      config = ThemeConfiguration.new(
        prefix: 'mytheme',
        font_heading: 'Inter',
        font_subtitle: 'Inter',
        font_body: 'Roboto',
        font_code: 'Fira Code'
      )
      scss = config.to_scss_variables_string
      expect(scss).to include('$mytheme-font-heading: "Inter";')
      expect(scss).to include('$mytheme-font-body: "Roboto";')
    end

    it 'includes shadow matrices' do
      config = ThemeConfiguration.new(
        prefix: 'test',
        text_shadow: '0.25rem 0.25rem 0.5rem rgba(5,5,5,0.5)',
        drop_shadow: '0.5rem 0.5rem 1rem rgba(1,1,1,0.25)'
      )
      scss = config.to_scss_variables_string
      expect(scss).to include('$test-text-shadow: 0.25rem 0.25rem 0.5rem rgba(5,5,5,0.5);')
      expect(scss).to include('$test-drop-shadow: 0.5rem 0.5rem 1rem rgba(1,1,1,0.25);')
    end
  end

  describe 'Shareable URLs Encoding/Decoding' do
    it 'round-trips attributes via base64 without data loss' do
      original = ThemeConfiguration.new(
        primary: '#ff0000',
        prefix: 'tester',
        font_body: 'Open Sans',
        margin_md: '30px'
      )
      
      encoded = original.to_base64
      expect(encoded).to be_a(String)
      
      decoded = ThemeConfiguration.from_base64(encoded)
      expect(decoded.primary).to eq('#ff0000')
      expect(decoded.prefix).to eq('tester')
      expect(decoded.font_body).to eq('Open Sans')
      expect(decoded.margin_md).to eq('30px')
    end

    it 'returns a default configuration if the base64 string is malformed' do
      decoded = ThemeConfiguration.from_base64("not_valid_base64!")
      expect(decoded.primary).to eq('#3b82f6') # Default
    end
  end
end
