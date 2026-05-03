class ZipAssemblerService
  def self.call(configuration, compiled_css, format = "all")
    new(configuration, compiled_css, format).call
  end

  def initialize(configuration, compiled_css, format)
    @configuration = configuration
    @compiled_css = compiled_css
    @format = format
  end

  def call
    require "zip"

    prefix = @configuration.prefix.presence || "nanocss"

    Zip::OutputStream.write_buffer do |out|
      if @format == "all" || @format == "min" || @format == "css"
        # Write compiled CSS
        out.put_next_entry("#{prefix}.css")
        out.write(@compiled_css)
      end

      if @format == "all" || @format == "min"
        # Write minified CSS
        out.put_next_entry("#{prefix}.min.css")
        out.write(@compiled_css.gsub(/\s+/, " ").strip)
      end

      if @format == "all" || @format == "scss"
        # Write SCSS partials
        base_path = Rails.root.join("app", "assets", "stylesheets", "nanocss")

        Dir.glob(File.join(base_path, "**", "*.scss")).each do |file_path|
          pn_file = Pathname.new(file_path)
          pn_base = Pathname.new(base_path)

          relative_path = if pn_file.absolute?
                            pn_file.relative_path_from(pn_base).to_s
          else
                            file_path.sub(%r{.*app/assets/stylesheets/nanocss/}, "")
          end

          is_component = relative_path.start_with?("components/")
          if is_component
            component_name = File.basename(relative_path, ".scss").sub(/^_/, "")
            next if @configuration.excluded_components.include?(component_name)
          end

          content = File.read(file_path)

          if relative_path.to_s == "_components.scss" && @configuration.respond_to?(:excluded_components) && @configuration.excluded_components.present?
            @configuration.excluded_components.each do |c|
              content.gsub!(/^(@use|@import)\s+['"]components\/#{Regexp.escape(c)}['"];?\s*$/, "")
              content.gsub!(/\/\*\s*\d+[a-z]?\.\s*#{Regexp.escape(c.capitalize)}\b.*?(?=\/\*\s*\d+[a-z]?\.|\z)/mi, "")
            end
          end

          out.put_next_entry("scss/#{relative_path}")
          out.write(content)
        end
      end
    end.string
  end
end
