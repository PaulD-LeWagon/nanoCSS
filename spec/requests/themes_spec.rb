require 'rails_helper'

# Traces: design/BACKLOG.md UC-001, UC-003, UC-004
RSpec.describe "Themes", type: :request do
  describe "GET / (Landing Page — UC-001 AC1)" do
    it "returns http success" do
      get root_path
      expect(response).to have_http_status(:success)
    end

    it "renders the three preset theme names" do
      get root_path
      expect(response.body).to include("Corporate")
      expect(response.body).to include("Playful")
      expect(response.body).to include("Minimalist")
    end
  end

  describe "GET /configure (Configuration Page)" do
    it "returns http success with default config" do
      get configure_path
      expect(response).to have_http_status(:success)
    end

    # UC-004 AC2: Share URL pre-populates
    it "pre-populates config from ?theme= parameter" do
      encoded = ThemeConfiguration.new(primary: '#ff0000', prefix: 'tester').to_base64
      get configure_path(theme: encoded)
      expect(response).to have_http_status(:success)
      expect(response.body).to include('#ff0000')
    end
  end

  describe "POST /themes/preview (Turbo Stream — UC-001 AC2, UC-002 AC4)" do
    it "returns a turbo stream response" do
      post theme_preview_path, params: { theme_configuration: { primary: "#ff0000" } },
           headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
      expect(response).to have_http_status(:success)
      expect(response.media_type).to eq('text/vnd.turbo-stream.html')
    end

    # Per ADR-003: preview swaps a <link href> — not an inline <style> tag.
    it "includes a stylesheet link swap in the turbo stream response" do
      post theme_preview_path, params: { theme_configuration: { primary: "#ff0000" } },
           headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
      expect(response.body).to include('/themes/css')
      expect(response.body).to include('nanocss-preview-style')
    end
  end

  # --- UC-023: Validation gate ---
  describe "POST /themes/preview with invalid params (UC-023)" do
    # Preview returns 200 even on validation failure — Turbo must process the error
    # turbo stream without triggering a page reload (which would break live typing).
    it "returns 200 with an error turbo stream for an invalid hex colour" do
      post theme_preview_path,
           params: { theme_configuration: { primary: "not-a-colour" } },
           headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('validation-errors')
    end

    it "returns 200 with an error turbo stream for a prefix exceeding 32 characters" do
      post theme_preview_path,
           params: { theme_configuration: { prefix: "a" * 33 } },
           headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('validation-errors')
    end

    # Download is a non-turbo endpoint — 422 is semantically correct here.
    it "returns 422 on download for an invalid hex colour" do
      post theme_download_path,
           params: { theme_configuration: { primary: "bad" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "does NOT update the stylesheet link when invalid" do
      post theme_preview_path,
           params: { theme_configuration: { primary: "not-a-colour" } },
           headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
      expect(response.body).not_to include('/themes/css')
    end
  end

  # UC-003: Download engine
  describe "POST /themes/download (UC-003)" do
    it "streams a ZIP file" do
      post theme_download_path, params: { theme_configuration: { primary: "#3b82f6" } }
      expect(response).to have_http_status(:success)
      expect(response.headers['Content-Type']).to include('application/zip')
    end

    it "names the ZIP after the configured prefix" do
      post theme_download_path, params: { theme_configuration: { prefix: "mycorp" } }
      expect(response.headers['Content-Disposition']).to include('mycorp.zip')
    end

    it "returns a valid ZIP containing {prefix}.css and {prefix}.min.css" do
      post theme_download_path, params: { theme_configuration: { prefix: "testdl" } }
      entries = []
      Zip::File.open_buffer(response.body) { |z| z.each { |e| entries << e.name } }
      expect(entries).to include('testdl.css')
      expect(entries).to include('testdl.min.css')
      expect(entries).to include('scss/_variables.scss')
    end
  end
end
