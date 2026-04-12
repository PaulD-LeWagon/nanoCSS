class ThemesController < ApplicationController
  def index
    @presets = [
      { name: "Corporate", primary: "#1e40af", default: true },
      { name: "Playful", primary: "#f43f5e" },
      { name: "Minimalist", primary: "#000000" }
    ]
  end

  def show
    if params[:theme].present?
      @config = ThemeConfiguration.from_base64(params[:theme])
    else
      @config = ThemeConfiguration.new
    end
    
    # Pre-compile the CSS to show the current state in normal load
    result = ScssCompilerService.call(@config)
    @css = result[:css] || ""
  end

  def preview
    @config = ThemeConfiguration.new(theme_params)
    result = ScssCompilerService.call(@config)
    @css = result[:css] || ""

    render turbo_stream: turbo_stream.update("nanocss-preview-style", "<style>#{@css}</style>")
  end

  def download
    @config = ThemeConfiguration.new(theme_params)
    result = ScssCompilerService.call(@config)
    
    zip_data = ZipAssemblerService.call(@config, result[:css])
    
    send_data zip_data, 
              type: 'application/zip', 
              disposition: "attachment; filename=\"#{@config.prefix.presence || 'nanocss'}.zip\""
  end

  private

  def theme_params
    return {} unless params.key?(:theme_configuration)
    params.require(:theme_configuration).permit(
      :primary, :secondary, :tertiary, :prefix,
      :font_heading, :font_subtitle, :font_body, :font_code,
      :base_typography, :base_space, :base_margin,
      :base_radius, :base_border_width,
      :text_shadow, :drop_shadow, :tier, :mode,
      :margin_md, :space_md
    )
  end
end
