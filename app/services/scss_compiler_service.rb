class ScssCompilerService
  def self.call(configuration, tier: :standard)
    new(configuration, tier).call
  end

  def initialize(configuration, tier)
    @configuration = configuration
    @tier = tier.to_sym
  end

  def call
    # 1. Read existing partials from the file system
    base_path = Rails.root.join('app', 'assets', 'stylesheets', 'nanocss')
    
    begin
      variables_scss = File.read(File.join(base_path, '_variables.scss'))
      mixins_scss = File.read(File.join(base_path, '_mixins.scss'))
      
      # For now, append standard utilities if standard or full tier
      utilities_scss = ""
      if [:standard, :full].include?(@tier)
        utilities_scss = File.read(File.join(base_path, '_utilities.scss'))
      end

      # We don't read components yet, will implement component toggles later
      # 2. Get dynamic variables prepended
      dynamic_vars = @configuration.to_scss_variables_string

      # Assemble the full string
      full_scss = [
        dynamic_vars,
        variables_scss,
        mixins_scss,
        utilities_scss
      ].join("\n\n")

      # 3. Execute Dart Sass compile
      result = Sass.compile_string(full_scss)
      
      { css: result.css, error: nil }
    rescue Sass::CompileError => e
      { css: nil, error: e.message }
    rescue StandardError => e
      { css: nil, error: "System Error: #{e.message}" }
    end
  end
end
