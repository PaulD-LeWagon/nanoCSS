require 'rails_helper'

# Traces: design/BACKLOG.md UC-006 AC1
RSpec.describe ColourHarmonyService do
  # Helper to assert roughly equal hex colours if there are minor rounding differences,
  # but standard algorithm outputs are generally precise.

  describe ".call" do
    it "returns complementary colour (180deg)" do
      # Example: Primary pure red #ff0000 -> Complementary #00ffff (cyan)
      result = described_class.call("#ff0000", harmony_type: :complementary)
      expect(result).to eq([ "#00ffff", "#00ffff" ]) # Complementary usually gives one opposing colour, but we return a pair (secondary/tertiary)
    end

    it "returns analogous colours (+30, -30)" do
      # Pure red #ff0000 -> Analogous #ff8000 (orange) and #ff0080 (magenta)
      result = described_class.call("#ff0000", harmony_type: :analogous)
      expect(result).to match_array([ "#ff8000", "#ff0080" ])
    end

    it "returns triadic colours (+120, +240)" do
      # Pure red #ff0000 -> Triadic #00ff00 (green), #0000ff (blue)
      result = described_class.call("#ff0000", harmony_type: :triadic)
      expect(result).to match_array([ "#00ff00", "#0000ff" ])
    end

    it "handles missing hex by returning defaults" do
      result = described_class.call(nil, harmony_type: :complementary)
      expect(result.length).to eq(2)
      expect(result).to all(match(/\A#[0-9a-fA-F]{6}\z/))
    end

    it "handles invalid hex gracefully" do
      result = described_class.call("#ZZZZZZ", harmony_type: :analogous)
      expect(result.length).to eq(2)
      expect(result).to all(match(/\A#[0-9a-fA-F]{6}\z/))
    end
  end
end
