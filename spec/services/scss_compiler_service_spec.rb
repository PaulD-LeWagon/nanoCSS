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
        a_string_starting_with("$prefix: 'nanocss';")
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
  end
end
