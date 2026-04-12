require 'rails_helper'

RSpec.describe ScssCompilerService do
  let(:config) do
    ThemeConfiguration.new(
      primary: '#3b82f6',
      prefix: 'nanocss',
      tier: 'standard'
    )
  end

  describe '.call' do
    before do
      # Mock the file system read to ensure it attempts to load actual partials
      # but we provide dummy files to prevent test dependencies on actual file state right now.
      allow(File).to receive(:read).and_return("")
      allow(File).to receive(:read).with(/_variables.scss/).and_return("$nanocss-base-space: 0.5rem !default;")
    end

    it 'returns a success object with compiled CSS' do
      result = ScssCompilerService.call(config)
      expect(result[:css]).to be_a(String)
      expect(result[:error]).to be_nil
    end

    it 'does NOT generate SCSS utility math natively, but reads from app/assets/stylesheets/nanocss/' do
      expect(File).to receive(:read).with(a_string_matching(%r{app/assets/stylesheets/nanocss/_variables.scss}))
      expect(File).to receive(:read).with(a_string_matching(%r{app/assets/stylesheets/nanocss/_utilities.scss}))
      
      ScssCompilerService.call(config)
    end

    it 'prepends the dynamic variables before passing to Dart Sass' do
      # We intercept Sass.compile_string to see what string was passed
      expect(Sass).to receive(:compile_string).with(
        a_string_including('$nanocss-primary: #3b82f6;'),
        anything
      ).and_call_original
      
      ScssCompilerService.call(config)
    end

    it 'handles compilation errors gracefully' do
      allow(Sass).to receive(:compile_string).and_raise(Sass::CompileError.new("Invalid CSS", nil, nil))
      result = ScssCompilerService.call(config)
      expect(result[:css]).to be_nil
      expect(result[:error]).to eq("Invalid CSS")
    end
  end
end
