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
  def self.call(configuration, tier: nil, scope: nil)
    tier ||= configuration.respond_to?(:tier) ? configuration.tier : :standard
    new(configuration, tier, scope: scope).call
  end

  def initialize(configuration, tier, scope: nil)
    @configuration = configuration
    @tier = tier.to_sym
    @scope = scope
  end

  def call
    base_path = Rails.root.join('app', 'assets', 'stylesheets', 'nanocss')

    begin
      # 1. Dynamic user overrides (prepended before !default declarations)
      dynamic_vars = "@use 'sass:color';\n" + @configuration.to_scss_variables_string

      # 1b. Semantic Tints (UC-011)
      if @configuration.primary.present?
        semantic_tints = <<~SCSS
          $nanocss-success: color.mix(#10b981, #{@configuration.primary}, 90%) !default;
          $nanocss-info: color.mix(#0ea5e9, #{@configuration.primary}, 90%) !default;
          $nanocss-warning: color.mix(#f59e0b, #{@configuration.primary}, 90%) !default;
          $nanocss-danger: color.mix(#ef4444, #{@configuration.primary}, 90%) !default;
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
      if @scope.present?
        # PREVIEW MODE — minimal compilation to prevent full-page reflows.
        #
        # Problem: if we include _base.scss / _reset.scss in @layer config, those
        # files contain global selectors (body, h1, h2, etc.) that are parsed and
        # applied to the whole page every time the preview stylesheet reloads,
        # causing the visible full-page CSS reflow the user sees.
        #
        # Solution: Only compile what the preview actually needs to change:
        #   1. CSS custom properties, scoped to #preview-canvas — variables
        #      cascade to all child elements, so every var(--nanocss-*) reference
        #      in the component classes automatically picks up the new values.
        #   2. Component classes (if tier permits) — these are already global
        #      selectors and don't interact with body/html/h1 etc.
        #
        # _base.scss, _reset.scss and _utilities.scss are deliberately omitted:
        # they are already compiled into @layer framework via nanocss.css and
        # do not need to be re-emitted every preview update.
        scoped_custom_props = custom_props_scss.gsub(/:root/, @scope)

        full_scss = [
          dynamic_vars,
          variables_scss,
          mixins_scss,
          scoped_custom_props,
          components_scss   # component selectors are global — safe to include
        ].join("\n\n")
      else
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
      end

      # Execute Dart Sass in-memory compilation
      result = Sass.compile_string(full_scss)
      
      css_output = result.css
      
      # Remove any @charset declaration added by Sass so it doesn't invalidate the layer block
      css_output = css_output.gsub(/@charset[^;]+;\n*/, '')

      # UC-012: CSS Layer block wrapping
      if @configuration.wrap_in_layer
        css_output = "@layer #{@configuration.prefix || 'nanocss'} {\n#{css_output}\n}"
      end

      # For preview mode, wrap the output in the config layer so it overrides
      # the framework layer, but do this BEFORE prepending Google Fonts!
      if @scope.present?
        css_output = "@layer config {\n#{css_output}\n}"
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
