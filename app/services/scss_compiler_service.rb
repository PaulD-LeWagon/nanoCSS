# Traces: design/SYSTEM_DESIGN.md §ScssCompilerService
# Traces: design/PRD.md §11.4, FR-005 (Tier system), FR-013 (Reset)
#
# Compilation order:
#   1. Dynamic user variables (override !default)
#   2. _variables.scss (framework defaults with !default)
#   3. _mixins.scss (utility generators, fluid-text, breakpoints)
#   4. _custom-properties.scss (maps SCSS vars → CSS custom properties)
#   5. _reset.scss (bespoke CSS reset — always included)
#   6. _base.scss (semantic HTML element styling — Nano tier)
#   7. _utilities.scss (Standard/Full tiers only)
class ScssCompilerService
  def self.call(configuration, tier: :standard)
    new(configuration, tier).call
  end

  def initialize(configuration, tier)
    @configuration = configuration
    @tier = tier.to_sym
  end

  def call
    base_path = Rails.root.join('app', 'assets', 'stylesheets', 'nanocss')

    begin
      # 1. Dynamic user overrides (prepended before !default declarations)
      dynamic_vars = @configuration.to_scss_variables_string

      # 2. Framework partials — always included
      variables_scss = File.read(File.join(base_path, '_variables.scss'))
      mixins_scss    = File.read(File.join(base_path, '_mixins.scss'))

      # 3. CSS Custom Properties (maps SCSS vars → :root { --prefix-* })
      custom_props_scss = File.read(File.join(base_path, '_custom-properties.scss'))

      # 4. Bespoke reset — always included (FR-013)
      reset_scss = File.read(File.join(base_path, '_reset.scss'))

      # 5. Semantic HTML base styling — Nano tier (FR-005)
      base_scss = File.read(File.join(base_path, '_base.scss'))

      # 6. Standard tier: utility classes
      utilities_scss = ""
      if [:standard, :full].include?(@tier)
        utilities_scss = File.read(File.join(base_path, '_utilities.scss'))
      end

      # Assemble in correct dependency order
      full_scss = [
        dynamic_vars,
        variables_scss,
        mixins_scss,
        custom_props_scss,
        reset_scss,
        base_scss,
        utilities_scss
      ].join("\n\n")

      # Execute Dart Sass in-memory compilation
      result = Sass.compile_string(full_scss)

      { css: result.css, error: nil }
    rescue Sass::CompileError => e
      { css: nil, error: e.message }
    rescue StandardError => e
      { css: nil, error: "System Error: #{e.message}" }
    end
  end
end
