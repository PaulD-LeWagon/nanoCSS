require "rails_helper"
require "net/http"
require "uri"
require "json"

# UC-041: Validates that the default-config compiled CSS passes the W3C CSS validator.
# This spec is tagged :css_validation and skipped unless the W3C API is reachable.
# In CI the validate_css job in .github/workflows/ci.yml runs this independently.
RSpec.describe "W3C CSS Validation", :css_validation do
  let(:css) do
    result = ScssCompilerService.call(ThemeConfiguration.new)
    result[:css]
  end

  it "default-config compiled CSS has zero W3C errors" do
    uri = URI("https://jigsaw.w3.org/css-validator/validator")
    response = Net::HTTP.post_form(uri, {
      "text"    => css,
      "profile" => "css3svg",
      "output"  => "json",
      "warning" => "0"
    })

    data = JSON.parse(response.body)
    error_count = data.dig("cssvalidation", "result", "errorcount").to_i

    errors = data.dig("cssvalidation", "errors", "errorlist") || []
    error_messages = errors.map { |e| e["message"] }.join("\n")

    expect(error_count).to eq(0),
      "W3C CSS validator reported #{error_count} error(s):\n#{error_messages}"
  rescue SocketError, Errno::ECONNREFUSED, Net::OpenTimeout => e
    skip "W3C validator unreachable (#{e.class}): #{e.message}"
  rescue JSON::ParserError
    skip "W3C validator returned non-JSON response (service unavailable or rate-limited)"
  end
end
