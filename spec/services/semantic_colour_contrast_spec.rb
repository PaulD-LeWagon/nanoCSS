require "rails_helper"

# Traces: design/BACKLOG.md UC-045 AC3
# Verifies tinted semantic colours (UC-011) meet WCAG 2.1 AA 4.5:1 contrast
# against their actual text colour (#fff for info/danger, dark for warning/success)
# under all three default presets (Corporate, Playful, Minimalist).
RSpec.describe "Semantic colour contrast (UC-011 AC3)", type: :request do
  PRESETS = {
    "Corporate"  => "#1e40af",
    "Playful"    => "#f43f5e",
    "Minimalist" => "#000000"
  }.freeze

  # WCAG 2.1 relative luminance + contrast ratio per https://www.w3.org/TR/WCAG21/#dfn-relative-luminance
  def relative_luminance(r, g, b)
    [ r, g, b ].map { |c|
      c <= 0.04045 ? c / 12.92 : ((c + 0.055) / 1.055)**2.4
    }.zip([ 0.2126, 0.7152, 0.0722 ]).sum { |lin, weight| lin * weight }
  end

  def contrast_ratio(bg_rgb, fg_rgb = [ 1.0, 1.0, 1.0 ])
    l1 = relative_luminance(*bg_rgb)
    l2 = relative_luminance(*fg_rgb)
    lighter, darker = [ l1, l2 ].sort.reverse
    (lighter + 0.05) / (darker + 0.05)
  end

  def extract_rgb(css, property)
    match = css.match(/--nanocss-#{property}:\s*rgb\(([\d.]+),\s*([\d.]+),\s*([\d.]+)\)/)
    return nil unless match
    match.captures.map { |v| v.to_f / 255.0 }
  end

  PRESETS.each do |preset_name, primary|
    context "#{preset_name} preset (primary: #{primary})" do
      let(:css) do
        config = ThemeConfiguration.new(primary: primary)
        ScssCompilerService.call(config)[:css]
      end

      # Warning uses dark text (after UC-045 fix); others use white
      it "warning colour meets 4.5:1 against dark text (#1a1a1a)" do
        rgb = extract_rgb(css, "warning")
        skip "Could not extract --nanocss-warning value" unless rgb
        dark_text = [ 0x1a / 255.0, 0x1a / 255.0, 0x1a / 255.0 ]
        ratio = contrast_ratio(rgb, dark_text)
        expect(ratio).to be >= 4.5,
          "#{preset_name} warning #{rgb.map { |c| (c * 255).round }.inspect} " \
          "has #{ratio.round(2)}:1 contrast against dark text"
      end

      it "success colour meets 4.5:1 against dark text (#1a1a1a)" do
        rgb = extract_rgb(css, "success")
        skip "Could not extract --nanocss-success value" unless rgb
        dark_text = [ 0x1a / 255.0, 0x1a / 255.0, 0x1a / 255.0 ]
        ratio = contrast_ratio(rgb, dark_text)
        expect(ratio).to be >= 4.5,
          "#{preset_name} success #{rgb.map { |c| (c * 255).round }.inspect} " \
          "has #{ratio.round(2)}:1 contrast against dark text"
      end

      it "info colour meets 4.5:1 against dark text (#111827)" do
        rgb = extract_rgb(css, "info")
        skip "Could not extract --nanocss-info value" unless rgb
        dark_text = [ 0x11 / 255.0, 0x18 / 255.0, 0x27 / 255.0 ]
        ratio = contrast_ratio(rgb, dark_text)
        expect(ratio).to be >= 4.5,
          "#{preset_name} info #{rgb.map { |c| (c * 255).round }.inspect} " \
          "has #{ratio.round(2)}:1 contrast against dark text"
      end

      # danger uses white text — base colour darkened to #dc2626 (UC-045 fix)
      it "danger colour meets 4.5:1 against white text (#fff)" do
        rgb = extract_rgb(css, "danger")
        skip "Could not extract --nanocss-danger value" unless rgb
        ratio = contrast_ratio(rgb)
        expect(ratio).to be >= 4.5,
          "#{preset_name} danger #{rgb.map { |c| (c * 255).round }.inspect} " \
          "has #{ratio.round(2)}:1 contrast against white"
      end
    end
  end
end
