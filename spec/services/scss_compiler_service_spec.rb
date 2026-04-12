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
