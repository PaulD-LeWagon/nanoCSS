require 'rails_helper'
require 'zip'

# Traces: design/BACKLOG.md UC-003
# Traces: design/SYSTEM_DESIGN.md §ZipAssemblerService
RSpec.describe ZipAssemblerService do
  # NO MOCKS — test with real compiled CSS from the real compiler
  let(:config) { ThemeConfiguration.new(prefix: 'nanocss') }
  let(:compiled_css) do
    result = ScssCompilerService.call(config)
    result[:css]
  end

  describe '.call with real data' do
    it 'returns valid ZIP binary data' do
      zip_data = described_class.call(config, compiled_css)
      expect(zip_data).to be_a(String)
      expect(zip_data[0..1]).to eq('PK') # ZIP magic bytes
    end

    # UC-003 AC2: Archive contains {prefix}.css, {prefix}.min.css, scss/ directory
    it 'contains {prefix}.css and {prefix}.min.css' do
      zip_data = described_class.call(config, compiled_css)
      entries = extract_entry_names(zip_data)
      expect(entries).to include('nanocss.css')
      expect(entries).to include('nanocss.min.css')
    end

    it 'contains scss/ directory with the framework partials' do
      zip_data = described_class.call(config, compiled_css)
      entries = extract_entry_names(zip_data)
      expect(entries).to include('scss/_variables.scss')
      expect(entries).to include('scss/_mixins.scss')
      expect(entries).to include('scss/_utilities.scss')
    end

    # UC-032 AC4: ZIP ships the modular component tree
    it 'AC4: ZIP includes individual component partials from components/ directory' do
      zip_data = described_class.call(config, compiled_css)
      entries = extract_entry_names(zip_data)
      expect(entries).to include('scss/components/_nav.scss')
      expect(entries).to include('scss/components/_card.scss')
      expect(entries).to include('scss/components/_buttons.scss')
    end

    it 'AC4: excluded components are omitted from the ZIP scss/components/ tree' do
      config.excluded_components = [ 'modal' ]
      css = ScssCompilerService.call(config)[:css]
      zip_data = described_class.call(config, css)
      entries = extract_entry_names(zip_data)
      expect(entries).not_to include('scss/components/_modal.scss')
      expect(entries).to include('scss/components/_card.scss')
    end

    # UC-003 AC3: Custom prefix respected in filenames
    it 'uses the custom prefix for CSS filenames' do
      config.prefix = 'mytheme'
      css = ScssCompilerService.call(config)[:css]
      zip_data = described_class.call(config, css)
      entries = extract_entry_names(zip_data)
      expect(entries).to include('mytheme.css')
      expect(entries).to include('mytheme.min.css')
      expect(entries).not_to include('nanocss.css')
    end

    it 'the {prefix}.min.css is smaller than {prefix}.css' do
      zip_data = described_class.call(config, compiled_css)
      full_size = 0
      min_size = 0
      Zip::File.open_buffer(zip_data) do |zip|
        full_size = zip.find_entry('nanocss.css').size
        min_size = zip.find_entry('nanocss.min.css').size
      end
      expect(min_size).to be < full_size
    end
  end

  private

  def extract_entry_names(zip_data)
    names = []
    Zip::File.open_buffer(zip_data) { |zip| zip.each { |e| names << e.name } }
    names
  end
end
