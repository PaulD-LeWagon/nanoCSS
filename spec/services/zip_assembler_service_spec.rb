require 'rails_helper'

RSpec.describe ZipAssemblerService do
  let(:config) { ThemeConfiguration.new(prefix: 'nanocss') }
  let(:compiled_css) { ".nanocss-primary { color: #3b82f6; }" }

  describe '.call' do
    before do
      # Mock the file system to pretend we have real partials
      allow(Dir).to receive(:glob).and_return([
        'app/assets/stylesheets/nanocss/_variables.scss',
        'app/assets/stylesheets/nanocss/_mixins.scss',
        'app/assets/stylesheets/nanocss/components/_buttons.scss'
      ])
      allow(File).to receive(:read).and_return('// mock scss content')
      allow(File).to receive(:basename).and_call_original
      allow(File).to receive(:dirname).and_call_original
    end

    it 'returns a binary string representing a valid ZIP archive' do
      zip_data = ZipAssemblerService.call(config, compiled_css)
      expect(zip_data).to be_a(String)
      expect(zip_data[0..1]).to eq("PK") # ZIP file signature
    end

    it 'maps the app/assets/stylesheets/nanocss partials into the scss/ directory' do
      zip_data = ZipAssemblerService.call(config, compiled_css)
      files = []
      Zip::File.open_buffer(zip_data) do |zip|
        zip.each { |entry| files << entry.name }
      end

      expect(files).to include('scss/_variables.scss')
      expect(files).to include('scss/_mixins.scss')
      expect(files).to include('scss/components/_buttons.scss')
    end

    it 'injects the compiled css as correctly prefixed filenames' do
      config.prefix = 'mytheme'
      zip_data = ZipAssemblerService.call(config, compiled_css)
      
      files = []
      Zip::File.open_buffer(zip_data) do |zip|
        zip.each { |entry| files << entry.name }
      end

      expect(files).to include('mytheme.css')
      expect(files).to include('mytheme.min.css')
      expect(files).not_to include('nanocss.css')
    end
  end
end
