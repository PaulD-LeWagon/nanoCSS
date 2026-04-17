class GoogleFontsService
  require 'net/http'
  require 'json'

  API_URL = 'https://fonts.google.com/metadata/fonts'.freeze

  def self.catalogue
    Rails.cache.fetch('google_fonts_catalogue', expires_in: 24.hours) do
      fetch_fonts
    end
  end

  def self.fetch_fonts
    uri = URI(API_URL)
    response = Net::HTTP.get_response(uri)
    
    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      data['familyMetadataList'].map { |font| font['family'] } || []
    else
      # Fallback to standard safe web fonts if API is unreachable
      ['Inter', 'Roboto', 'Oswald', 'Fira Code', 'Source Code Pro', 'JetBrains Mono', 'Merriweather']
    end
  rescue StandardError => e
    Rails.logger.error("GoogleFontsService error: #{e.message}")
    ['Inter', 'Roboto', 'Oswald', 'Fira Code', 'Source Code Pro', 'JetBrains Mono', 'Merriweather']
  end
end
