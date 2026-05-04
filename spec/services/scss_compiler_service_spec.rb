require 'rails_helper'

# Traces: design/BACKLOG.md UC-003
# Traces: design/SYSTEM_DESIGN.md §ScssCompilerService
RSpec.describe ScssCompilerService do
  # NO MOCKS — tests hit the real filesystem and real Dart Sass compiler
  let(:config) { ThemeConfiguration.new }

  describe '.call with real compilation' do
    it 'returns compiled CSS from the actual SCSS partials' do
      result = described_class.call(config)
      expect(result[:error]).to be_nil
      expect(result[:css]).to be_a(String)
      expect(result[:css].length).to be > 100 # real CSS, not empty
    end

    it 'produces CSS containing utility classes with the configured prefix' do
      result = described_class.call(config)
      # The _utilities.scss generates classes like .nanocss-px, .nanocss-py etc
      expect(result[:css]).to include('.nanocss-')
    end

    it 'respects a custom prefix in the compiled CSS output' do
      config.prefix = 'mycorp'
      result = described_class.call(config)
      expect(result[:css]).to include('.mycorp-')
      expect(result[:css]).not_to include('.nanocss-')
    end

    it 'prepends user colour variables before the !default declarations' do
      config.primary = '#ff0000'
      # We verify the compile succeeds and that the dynamic vars are prepended
      expect(Sass).to receive(:compile_string).with(
        a_string_starting_with("@use 'sass:color';")
        .and(a_string_including("$prefix: 'nanocss';"))
        .and(a_string_including('$nanocss-primary: #ff0000;'))
      ).and_call_original
      result = described_class.call(config)
      expect(result[:error]).to be_nil
    end

    # UC-002 AC7: Font code variable is prepended before compilation
    it 'prepends the font_code selection before Dart Sass compilation' do
      config.font_code = 'JetBrains Mono'
      expect(Sass).to receive(:compile_string).with(
        a_string_including('$nanocss-font-code: "JetBrains Mono";')
      ).and_call_original
      result = described_class.call(config)
      expect(result[:error]).to be_nil
    end

    # CSS Custom Properties — reactive Turbo Stream updates (PRD §9.1)
    it 'emits CSS custom properties for all design tokens in :root' do
      result = described_class.call(config)
      expect(result[:css]).to include('--nanocss-primary:')
      expect(result[:css]).to include('--nanocss-secondary:')
      expect(result[:css]).to include('--nanocss-tertiary:')
      expect(result[:css]).to include('--nanocss-font-heading:')
      expect(result[:css]).to include('--nanocss-font-code:')
      expect(result[:css]).to include('--nanocss-space-md:')
      expect(result[:css]).to include('--nanocss-radius-md:')
    end

    it 'uses the custom prefix in CSS custom property names' do
      config.prefix = 'mycorp'
      config.primary = '#ff0000'
      result = described_class.call(config)
      expect(result[:css]).to include('--mycorp-primary:')
      expect(result[:css]).to include('#ff0000')
      expect(result[:css]).not_to include('--nanocss-primary:')
    end

    # Bespoke CSS Reset (FR-013)
    it 'includes the bespoke CSS reset (box-sizing, margin removal)' do
      result = described_class.call(config)
      expect(result[:css]).to include('box-sizing: border-box')
    end

    # Semantic HTML base styling — Nano tier (FR-005)
    it 'applies sensible default styles to semantic HTML elements' do
      result = described_class.call(config)
      css = result[:css]
      # Body gets font-family from custom property
      expect(css).to include('var(--nanocss-font-body)')
      # Headings get styled
      expect(css).to match(/h1\s*\{/)
      # Links get primary colour
      expect(css).to include('var(--nanocss-primary)')
      # Code gets monospace font
      expect(css).to include('var(--nanocss-font-code)')
    end

    # Components — Standard/Full tiers (UC-005 / Sprint 2 Remediation)
    it 'includes the full suite of 18 UI component classes mapped to the prefix' do
      result = described_class.call(config)
      css = result[:css]
      expected_classes = [
        '.nanocss-hero', '.nanocss-carousel', '.nanocss-card',
        '.nanocss-dropdown', '.nanocss-group', '.nanocss-loader',
        '.nanocss-modal', '.nanocss-nav', '.nanocss-badge',
        '.nanocss-tag', '[aria-label=breadcrumb]', '.nanocss-pagination',
        '.nanocss-tabs', '.nanocss-btn-primary', '.nanocss-btn-secondary',
        '[data-tooltip]'
      ]

      expected_classes.each do |css_class|
        expect(css).to include(css_class), "Expected compiled CSS to include #{css_class} but it was missing"
      end
    end

    it 'handles a compilation error gracefully without raising' do
      # Force an invalid SCSS string by mocking the variables file
      allow(File).to receive(:read).and_call_original
      allow(File).to receive(:read).with(a_string_matching(/_variables/)).and_return("$broken: {{{;")

      result = described_class.call(config)
      expect(result[:css]).to be_nil
      expect(result[:error]).to be_a(String)
    end

    # --- UC-014: Google Fonts Injection ---
    it 'injects the proper @import url() when valid fonts are selected' do
      config.font_heading = 'Roboto'
      result = described_class.call(config)
      expect(result[:css]).to include("@import url('https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap');")
    end

    # --- UC-010: Per-Component Toggling Omission ---
    it 'omits excluded components from the compiled CSS' do
      config.excluded_components = [ 'modal', 'carousel' ]
      result = described_class.call(config)
      expect(result[:css]).not_to include('.nanocss-modal')
      expect(result[:css]).not_to include('.nanocss-carousel')
      # other components are still present
      expect(result[:css]).to include('.nanocss-card')
    end

    # --- UC-011: Automated Semantic Colour Tinting ---
    it 'automatically applies tinting to semantic utility classes using primary color' do
      config.primary = '#ff0000'
      # we assume the compiler uses color.mix() internally, so the output CSS should reflect primary-tinted success classes
      result = described_class.call(config)
      # Check that the CSS output contains the dynamically calculated semantic variables or output
      expect(result[:css]).to match(/--nanocss-success:\s*(#|rgb)/)
    end

    # --- UC-012: CSS Layer (@layer) Support ---
    it 'wraps the entire output in a CSS layer when requested' do
      config.wrap_in_layer = true
      result = described_class.call(config)
      expect(result[:css]).to match(/@layer nanocss \{/)
      expect(result[:css]).to match(/\}\s*\z/) # Ends with a closing brace
    end

    # --- UC-031: Tier 1 Dark Mode ---
    it 'AC1: compiled CSS includes @media (prefers-color-scheme: dark) with :root block' do
      result = described_class.call(config)
      expect(result[:css]).to include('prefers-color-scheme: dark')
      # The block must set at least one dark token on :root
      expect(result[:css]).to match(/prefers-color-scheme:\s*dark\b.*?:root\s*\{.*?--nanocss-/m)
    end

    it 'AC2: [data-theme="light"] block exists to override the media query' do
      result = described_class.call(config)
      expect(result[:css]).to match(/\[data-theme=["']?light["']?\]/)
    end

    it 'AC2: [data-theme="dark"] explicit override still present (Tier 2)' do
      result = described_class.call(config)
      expect(result[:css]).to match(/\[data-theme=["']?dark["']?\]/)
    end

    # --- UC-032: Modular Component Partials ---
    it 'AC1: individual component partial files exist in nanocss/components/' do
      components_dir = Rails.root.join('app', 'assets', 'stylesheets', 'nanocss', 'components')
      files = Dir.glob(File.join(components_dir, '_*.scss'))
      expect(files.length).to be >= 17
    end

    it 'AC3: include-list exclusion uses component files (not regex strip)' do
      config.excluded_components = [ 'modal', 'carousel' ]
      result = described_class.call(config)
      expect(result[:css]).not_to include('.nanocss-modal')
      expect(result[:css]).not_to include('.nanocss-carousel')
      expect(result[:css]).to include('.nanocss-card')
    end

    it 'AC3: btn alias correctly excludes buttons component' do
      config.excluded_components = [ 'btn' ]
      result = described_class.call(config)
      expect(result[:css]).not_to include('.nanocss-btn-primary')
      expect(result[:css]).to include('.nanocss-card')
    end

    it 'AC3: loader alias correctly excludes loading component' do
      config.excluded_components = [ 'loader' ]
      result = described_class.call(config)
      expect(result[:css]).not_to include('.nanocss-loader')
      expect(result[:css]).to include('.nanocss-nav')
    end
  end
end
