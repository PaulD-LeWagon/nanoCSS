require 'rails_helper'

RSpec.describe "Themes", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/themes/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/themes/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /preview" do
    it "returns http success" do
      get "/themes/preview"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /download" do
    it "returns http success" do
      get "/themes/download"
      expect(response).to have_http_status(:success)
    end
  end

end
