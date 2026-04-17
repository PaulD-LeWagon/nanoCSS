require 'rails_helper'

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

    let(:mock_response) { instance_double(Net::HTTPSuccess, is_a?: true, body: mock_json) }
    let(:error_response) { instance_double(Net::HTTPInternalServerError, is_a?: false) }

    before do
      Rails.cache.clear
    end

    it 'fetches and returns a list of font families from the Google Fonts API' do
      allow(Net::HTTP).to receive(:get_response).and_return(mock_response)

      fonts = described_class.catalogue
      expect(fonts).to include('Open Sans', 'Roboto')
      expect(fonts).to be_an(Array)
    end

    it 'falls back to a default list if the API returns an error' do
      allow(Net::HTTP).to receive(:get_response).and_return(error_response)

      fonts = described_class.catalogue
      expect(fonts).to include('Inter', 'Fira Code')
    end

    it 'uses live API for the final E2E test', :live do
      # In the live test we call the actual remote network without mocks
      fonts = described_class.fetch_fonts
      expect(fonts).to be_an(Array)
      expect(fonts.size).to be > 100
      expect(fonts).to include('Roboto')
    end
  end
end
