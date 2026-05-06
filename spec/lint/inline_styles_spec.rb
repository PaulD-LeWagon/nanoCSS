require 'rails_helper'

# Traces: design/BACKLOG.md UC-034
# AC3: Spec fails CI if any *hardcoded* inline style= attribute is introduced.
#
# Rule: only flag style= values that contain no ERB interpolation (<%) AND
#       are not CSS-custom-property-only declarations (--var: value).
#       Dynamic colour swatches (style="background: <%= color %>") are
#       legitimately inline — they cannot be expressed as static CSS classes.
#
# Exemptions: component demo/test pages intentionally use inline styles to
#             showcase nanoCSS variable usage (they are content, not chrome).
RSpec.describe "No Hardcoded Inline Styles in App Views", type: :lint do
  INLINE_STYLE_EXEMPT = %w[
    app/views/components/index.html.erb
    app/views/components/test_page.html.erb
  ].freeze

  CSS_CUSTOM_PROP_ONLY = /\Astyle="(\s*--[\w-]+:\s*[^;"]+;?\s*)+"\z/

  let(:view_files) do
    Dir.glob(Rails.root.join("app/views/**/*.erb")).map(&:to_s).reject do |f|
      INLINE_STYLE_EXEMPT.any? { |exempt| f.end_with?(exempt) }
    end
  end

  it "AC1: zero hardcoded inline style= attributes across non-demo app views" do
    offenders = []

    view_files.each do |file|
      content = File.read(file)
      content.lines.each_with_index do |line, idx|
        next unless line =~ /\bstyle="[^"]*"/
        next if line.include?("<%")                         # dynamic ERB value — allowed
        next if line.match?(CSS_CUSTOM_PROP_ONLY)           # CSS custom prop only — allowed

        offenders << "#{file.sub(Rails.root.to_s + '/', '')}:#{idx + 1}: #{line.strip}"
      end
    end

    expect(offenders).to be_empty,
      "Hardcoded inline style= attributes found:\n  #{offenders.join("\n  ")}\n" \
      "Replace with nanoCSS utility classes or application.css rules."
  end
end
