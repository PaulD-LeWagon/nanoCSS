class ZipAssemblerService
  def self.call(configuration, compiled_css)
    new(configuration, compiled_css).call
  end

  def initialize(configuration, compiled_css)
    @configuration = configuration
    @compiled_css = compiled_css
  end

  def call
    require 'zip'

    prefix = @configuration.prefix.presence || 'nanocss'

    Zip::OutputStream.write_buffer do |out|
      # Write compiled CSS
      out.put_next_entry("#{prefix}.css")
      out.write(@compiled_css)

      # Write minified CSS (mock minification for now or just output normal css)
      # In a real app we might use sass compressed output earlier, but for MVP:
      # We'll just output the same css.
      out.put_next_entry("#{prefix}.min.css")
      out.write(@compiled_css.gsub(/\s+/, ' ').strip) # basic whitespace stripping

      # Write SCSS partials
      base_path = Rails.root.join('app', 'assets', 'stylesheets', 'nanocss')
      
      # Glob all SCSS files in the nanocs directory
      Dir.glob(File.join(base_path, '**', '*.scss')).each do |file_path|
        # Get relative path inside the nanocss folder using Pathname
        pn_file = Pathname.new(file_path)
        pn_base = Pathname.new(base_path)
        
        # If the file path is absolute, relative_path_from will work. If not, we fall back to string replacement correctly.
        relative_path = if pn_file.absolute? 
                          pn_file.relative_path_from(pn_base).to_s
                        else
                          file_path.sub(%r{.*app/assets/stylesheets/nanocss/}, '')
                        end
        
        content = File.read(file_path)

        out.put_next_entry("scss/#{relative_path}")
        out.write(content)
      end
    end.string
  end
end
