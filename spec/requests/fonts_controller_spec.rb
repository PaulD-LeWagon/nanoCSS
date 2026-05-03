require 'rails_helper'

RSpec.describe "Fonts API", type: :request do
  describe "GET /fonts" do
    it "returns the list of available fonts as JSON" do
      allow(GoogleFontsService).to receive(:catalogue).and_return([ 'Roboto', 'Inter' ])

      get '/fonts'

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json['fonts']).to include('Roboto', 'Inter')
    end
  end
end
