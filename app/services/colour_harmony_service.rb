class ColourHarmonyService
  # Harmonizes a given hex colour and returns an array of hex colours.
  # harmony_type can be: :complementary, :analogous, :triadic
  def self.call(primary_hex, harmony_type: :complementary)
    primary_hex = "#3b82f6" if primary_hex.blank? || !primary_hex.match?(/\A#[0-9a-fA-F]{6}\z/i)
    
    rgb = hex_to_rgb(primary_hex)
    hsl = rgb_to_hsl(*rgb)

    h, s, l = hsl

    case harmony_type
    when :complementary
      # +180 deg
      h_comp = (h + 180) % 360
      c1 = rgb_to_hex(*hsl_to_rgb(h_comp, s, l))
      [c1, c1]
    when :analogous
      # +30 deg and -30 deg
      h1 = (h + 30) % 360
      h2 = (h - 30) % 360
      [rgb_to_hex(*hsl_to_rgb(h1, s, l)), rgb_to_hex(*hsl_to_rgb(h2, s, l))]
    when :triadic
      # +120 deg and +240 deg
      h1 = (h + 120) % 360
      h2 = (h + 240) % 360
      [rgb_to_hex(*hsl_to_rgb(h1, s, l)), rgb_to_hex(*hsl_to_rgb(h2, s, l))]
    else
      [primary_hex, primary_hex]
    end
  end

  private

  def self.hex_to_rgb(hex)
    hex = hex.delete('^0-9a-fA-F')
    [hex[0..1].hex, hex[2..3].hex, hex[4..5].hex]
  end

  def self.rgb_to_hex(r, g, b)
    format('#%02x%02x%02x', r, g, b)
  end

  def self.rgb_to_hsl(r, g, b)
    r /= 255.0
    g /= 255.0
    b /= 255.0

    max = [r, g, b].max
    min = [r, g, b].min
    l = (max + min) / 2.0

    if max == min
      h = s = 0.0 # achromatic
    else
      d = max - min
      s = l > 0.5 ? d / (2.0 - max - min) : d / (max + min)
      
      h = case max
          when r then (g - b) / d + (g < b ? 6.0 : 0.0)
          when g then (b - r) / d + 2.0
          when b then (r - g) / d + 4.0
          end
      h /= 6.0
    end

    [(h * 360).round, s, l]
  end

  def self.hsl_to_rgb(h, s, l)
    h /= 360.0

    if s == 0
      r = g = b = l # achromatic
    else
      q = l < 0.5 ? l * (1.0 + s) : l + s - l * s
      p = 2.0 * l - q
      r = hue_to_rgb(p, q, h + 1.0/3.0)
      g = hue_to_rgb(p, q, h)
      b = hue_to_rgb(p, q, h - 1.0/3.0)
    end

    [(r * 255).round, (g * 255).round, (b * 255).round]
  end

  def self.hue_to_rgb(p, q, t)
    t += 1 if t < 0
    t -= 1 if t > 1
    return p + (q - p) * 6.0 * t if t < 1.0/6.0
    return q if t < 1.0/2.0
    return p + (q - p) * (2.0/3.0 - t) * 6.0 if t < 2.0/3.0
    p
  end
end
