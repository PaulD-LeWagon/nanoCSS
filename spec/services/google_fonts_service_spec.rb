require 'rails_helper'
require 'webmock/rspec'

RSpec.describe GoogleFontsService, type: :model do
  describe '.catalogue' do
    let(:mock_json) do
      {
        'familyMetadataList' => [
          { 'family' => 'Open Sans' },
          { 'family' => 'Roboto' }
        ]
      }.to_json
    end

    before do
      Rails.cache.clear
    end

    it 'fetches and returns a list of font families from the Google Fonts API' do
      stub_request(:get, GoogleFontsService::API_URL)
        .to_return(status: 200, body: mock_json)

      fonts = described_class.catalogue
      expect(fonts).to include('Open Sans', 'Roboto')
      expect(fonts).to be_an(Array)
    end

    it 'falls back to a default list if the API returns an error' do
      stub_request(:get, GoogleFontsService::API_URL)
        .to_return(status: 500)

      fonts = described_class.catalogue
      expect(fonts).to include('Inter', 'Fira Code')
    end

    it 'uses live API for the final E2E test', :live do
      WebMock.allow_net_connect!
      fonts = described_class.fetch_fonts
      expect(fonts).to be_an(Array)
      expect(fonts.size).to be > 100
      expect(fonts).to include('Roboto')
      WebMock.disable_net_connect!(allow_localhost: true)
    end
  end
end
