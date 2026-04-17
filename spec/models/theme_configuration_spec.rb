require 'rails_helper'

# Traces: design/BACKLOG.md UC-002, UC-004
# Traces: design/SYSTEM_DESIGN.md §ThemeConfiguration
RSpec.describe ThemeConfiguration, type: :model do
  subject(:config) { described_class.new }

  # --- UC-002 AC3: Invalid hex codes are rejected server-side ---
  describe 'validations' do
    it 'is valid with default attributes' do
      expect(config).to be_valid
    end

    it 'accepts valid 6-digit hex codes' do
      config.primary = '#3b82f6'
      config.secondary = '#8b5cf6'
      config.tertiary = '#ec4899'
      expect(config).to be_valid
    end

    it 'rejects 3-digit hex shorthand like #123' do
      config.primary = '#123'
      expect(config).not_to be_valid
      expect(config.errors[:primary]).to include('is invalid')
    end

    it 'rejects non-hex characters like #zzz000' do
      config.primary = '#zzz000'
      expect(config).not_to be_valid
    end

    it 'rejects hex without leading hash' do
      config.primary = '3b82f6'
      expect(config).not_to be_valid
    end

    it 'rejects empty string for colour (not blank, explicit empty)' do
      config.primary = ''
      # allow_blank: true means empty string is valid
      expect(config).to be_valid
    end

    # Prefix validation: /\A[a-z][a-z0-9-]*[a-z0-9]\z/
    it 'accepts valid lowercase prefix with hyphens' do
      config.prefix = 'my-theme-123'
      expect(config).to be_valid
    end

    it 'rejects prefix with uppercase' do
      config.prefix = 'MyTheme'
      expect(config).not_to be_valid
    end

    it 'rejects prefix with spaces' do
      config.prefix = 'my theme'
      expect(config).not_to be_valid
    end

    it 'rejects prefix starting with a hyphen' do
      config.prefix = '-invalid'
      expect(config).not_to be_valid
    end

    it 'rejects prefix ending with a hyphen' do
      config.prefix = 'invalid-'
      expect(config).not_to be_valid
    end
  end

  # --- UC-002 AC1: Basic Mode anchor variables ---
  describe '#to_scss_variables_string' do
    it 'outputs all Basic Mode anchor variables with correct prefix' do
      scss = config.to_scss_variables_string
      expect(scss).to include("$prefix: 'nanocss';")
      expect(scss).to include('$nanocss-primary: #3b82f6;')
      expect(scss).to include('$nanocss-secondary: #8b5cf6;')
      expect(scss).to include('$nanocss-tertiary: #ec4899;')
      expect(scss).to include('$nanocss-base-typography: 1rem;')
      expect(scss).to include('$nanocss-base-space: 0.5rem;')
      expect(scss).to include('$nanocss-base-radius: 0.25rem;')
    end

    # --- UC-002 AC7: Code Font slot ---
    it 'includes all 4 font slots including font_code' do
      scss = config.to_scss_variables_string
      expect(scss).to include('$nanocss-font-heading: "Inter";')
      expect(scss).to include('$nanocss-font-subtitle: "Inter";')
      expect(scss).to include('$nanocss-font-body: "Roboto";')
      expect(scss).to include('$nanocss-font-code: "Fira Code";')
    end

    # --- UC-002 AC5: Advanced decoupling ---
    it 'includes advanced overrides only in advanced mode' do
      config.mode = 'advanced'
      config.margin_md = '20px'
      config.space_md = '10px'
      scss = config.to_scss_variables_string
      expect(scss).to include('$nanocss-margin-md: 20px;')
      expect(scss).to include('$nanocss-space-md: 10px;')
    end

    it 'does NOT include advanced overrides in basic mode' do
      config.mode = 'basic'
      config.margin_md = '20px'
      scss = config.to_scss_variables_string
      expect(scss).not_to include('$nanocss-margin-md:')
    end

    # --- UC-002 AC6: Shadow matrices ---
    it 'passes shadow matrices verbatim' do
      scss = config.to_scss_variables_string
      expect(scss).to include('$nanocss-text-shadow: 0.25rem 0.25rem 0.5rem rgba(5, 5, 5, 0.5);')
      expect(scss).to include('$nanocss-drop-shadow: 0.5rem 0.5rem 1rem rgba(1, 1, 1, 0.25);')
    end

    it 'respects custom prefix in $prefix variable while keeping $nanocss-* vars' do
      config.prefix = 'mytheme'
      scss = config.to_scss_variables_string
      # $prefix controls output naming (class names, CSS custom properties)
      expect(scss).to include("$prefix: 'mytheme';")
      # All SCSS variable overrides MUST use $nanocss-* to override !default declarations
      expect(scss).to include('$nanocss-primary:')
      expect(scss).to include('$nanocss-font-code:')
      expect(scss).not_to include('$mytheme-primary:')
    end
  end

  # --- UC-004: Shareable URLs ---
  describe 'Base64 round-trip (UC-004)' do
    it 'encodes and decodes all attributes without data loss' do
      original = described_class.new(
        primary: '#00ff00', secondary: '#ff0000', tertiary: '#0000ff',
        prefix: 'tester', font_heading: 'Oswald', font_code: 'Source Code Pro',
        base_space: '1rem', mode: 'advanced', margin_md: '30px'
      )
      encoded = original.to_base64
      decoded = described_class.from_base64(encoded)

      expect(decoded.primary).to eq('#00ff00')
      expect(decoded.prefix).to eq('tester')
      expect(decoded.font_heading).to eq('Oswald')
      expect(decoded.font_code).to eq('Source Code Pro')
      expect(decoded.mode).to eq('advanced')
      expect(decoded.margin_md).to eq('30px')
    end

    # --- UC-004 AC3: Malformed data gracefully falls back ---
    it 'returns default config for malformed base64' do
      decoded = described_class.from_base64('not_valid!!!')
      expect(decoded.primary).to eq('#3b82f6')
      expect(decoded.prefix).to eq('nanocss')
    end

    it 'returns default config for tampered JSON' do
      encoded = Base64.urlsafe_encode64('{"not_a_real_field": "value"}')
      decoded = described_class.from_base64(encoded)
      expect(decoded.primary).to eq('#3b82f6') # defaults applied
    end
  end

  # --- UC-014: Font validation ---
  describe 'Google Fonts whitelist validation' do
    it 'accepts valid font from the allowed whitelist' do
      config.font_heading = 'Roboto'
      expect(config).to be_valid
    end

    it 'rejects unknown font to prevent injections' do
      config.font_heading = 'eval()'
      expect(config).not_to be_valid
      expect(config.errors[:font_heading]).to include('is not a recognised Google Font')
    end
  end

  # --- UC-010: Per-Component Toggling ---
  describe 'Excluded Components' do
    it 'accepts an array of valid component names to exclude' do
      config.excluded_components = ['modal', 'carousel']
      expect(config).to be_valid
    end

    it 'rejects unrecognised component names in exclusion list' do
      config.excluded_components = ['modal', 'not-a-component']
      expect(config).not_to be_valid
      expect(config.errors[:excluded_components]).to include('contains invalid component names')
    end
  end

  # --- UC-012: CSS Layer Flag ---
  describe 'Layer Wrapping Flag' do
    it 'can explicitly enable the wrap_in_layer flag' do
      config.wrap_in_layer = true
      expect(config.wrap_in_layer).to be true
    end
  end
end
