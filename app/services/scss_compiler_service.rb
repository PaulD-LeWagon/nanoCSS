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

      # 1b. Semantic Tints (UC-011)
      if @configuration.primary.present?
        semantic_tints = <<~SCSS
          $nanocss-success: mix(#10b981, #{@configuration.primary}, 90%) !default;
          $nanocss-info: mix(#0ea5e9, #{@configuration.primary}, 90%) !default;
          $nanocss-warning: mix(#f59e0b, #{@configuration.primary}, 90%) !default;
          $nanocss-danger: mix(#ef4444, #{@configuration.primary}, 90%) !default;
        SCSS
        dynamic_vars += "\n" + semantic_tints
      end

      # 2. Framework partials — always included
      variables_scss = File.read(File.join(base_path, '_variables.scss'))
      mixins_scss    = File.read(File.join(base_path, '_mixins.scss'))

      # 3. CSS Custom Properties (maps SCSS vars → :root { --prefix-* })
      custom_props_scss = File.read(File.join(base_path, '_custom-properties.scss'))

      # 4. Bespoke reset — always included (FR-013)
      reset_scss = File.read(File.join(base_path, '_reset.scss'))

      # 5. Semantic HTML base styling — Nano tier (FR-005)
      base_scss = File.read(File.join(base_path, '_base.scss'))

      # 5a. UI Components styling
      components_scss = ""
      if [:standard, :full].include?(@tier)
        components_scss = File.read(File.join(base_path, '_components.scss'))
        if @configuration.excluded_components.present?
          @configuration.excluded_components.each do |c|
            # Simple regex parser to strip out sections of the monolithic _components.scss based on header names
            components_scss.gsub!(/\/\*\s*\d+[a-z]?\.\s*#{Regexp.escape(c.capitalize)}\b.*?(?=\/\*\s*\d+[a-z]?\.|\z)/mi, "")
            
            # Special aliases due to file naming
            if c == 'btn' || c == 'button'
              components_scss.gsub!(/\/\*\s*\d+[a-z]?\.\s*Buttons?\b.*?(?=\/\*\s*\d+[a-z]?\.|\z)/mi, "")
            end
            if c == 'nav' || c == 'navbar'
              components_scss.gsub!(/\/\*\s*\d+[a-z]?\.\s*Nav\b.*?(?=\/\*\s*\d+[a-z]?\.|\z)/mi, "")
            end
            if c == 'loader'
              components_scss.gsub!(/\/\*\s*\d+[a-z]?\.\s*Loading\b.*?(?=\/\*\s*\d+[a-z]?\.|\z)/mi, "")
            end
          end
        end
      end

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
        components_scss,
        utilities_scss
      ].join("\n\n")

      # Execute Dart Sass in-memory compilation
      result = Sass.compile_string(full_scss)
      
      css_output = result.css
      
      # UC-012: CSS Layer block wrapping
      if @configuration.wrap_in_layer
        css_output = "@layer #{@configuration.prefix || 'nanocss'} {\n#{css_output}\n}"
      end
      
      # UC-014: Google Fonts Injection at top level
      font_imports = []
      fonts = [@configuration.font_heading, @configuration.font_subtitle, @configuration.font_body, @configuration.font_code]
      fonts.compact.reject(&:blank?).uniq.each do |font_name|
        formatted_name = font_name.gsub(' ', '+')
        font_imports << "@import url('https://fonts.googleapis.com/css2?family=#{formatted_name}:wght@300;400;500;700&display=swap');"
      end

      # Prepend fonts
      final_css = font_imports.empty? ? css_output : font_imports.join("\n") + "\n\n" + css_output

      { css: final_css, error: nil }
    rescue Sass::CompileError => e
      { css: nil, error: e.message }
    rescue StandardError => e
      { css: nil, error: "System Error: #{e.message}" }
    end
  end
end
