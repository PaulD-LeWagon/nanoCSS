class ThemesController < ApplicationController
  # Download is a stateless read operation — no server mutation occurs.
  # The CSRF token can fail when formaction overrides the original form target.
  skip_forgery_protection only: [:download, :css]
  def index
    @presets = [
      { name: "Corporate", primary: "#1e40af", secondary: "#6366f1", tertiary: "#06b6d4", default: true },
      { name: "Playful", primary: "#f43f5e", secondary: "#a855f7", tertiary: "#f97316" },
      { name: "Minimalist", primary: "#000000", secondary: "#404040", tertiary: "#737373" }
    ]
    # @nanocss_css is compiled by ApplicationController#compile_default_nanocss.
    # We alias it to @css so the landing page preview pane has it available if needed.
    @config = ThemeConfiguration.new
    @css = @nanocss_css
  end

  def show
    if params[:theme].present?
      @config = ThemeConfiguration.from_base64(params[:theme])
    else
      @config = ThemeConfiguration.new
    end

    # Pre-compile the CSS for the initial page render
    result = ScssCompilerService.call(@config, scope: '#preview-canvas')
    @css = result[:css] || ""
    
    @complementary = ColourHarmonyService.call(@config.primary, harmony_type: :complementary)
    @analogous = ColourHarmonyService.call(@config.primary, harmony_type: :analogous)
    @triadic = ColourHarmonyService.call(@config.primary, harmony_type: :triadic)
  end

  def preview
    @is_preview = request.referer&.include?('/configure')
    @config = ThemeConfiguration.new(theme_params)
    
    # We scope if it's the config page preview to prevent bleed.
    # On the landing page, we WANT global dogfooding as per PRD.
    scope = @is_preview ? '#preview-canvas' : nil
    result = ScssCompilerService.call(@config, scope: scope)
    @css = result[:css] || ""
    
    @complementary = ColourHarmonyService.call(@config.primary, harmony_type: :complementary)
    @analogous = ColourHarmonyService.call(@config.primary, harmony_type: :analogous)
    @triadic = ColourHarmonyService.call(@config.primary, harmony_type: :triadic)
    
    # Renders preview.turbo_stream.erb implicitly
  end

  def download
    config = ThemeConfiguration.new(theme_params)
    result = ScssCompilerService.call(config)

    if result[:css].nil?
      head :unprocessable_entity
      return
    end

    format = params[:download_format] || 'all'

    if format == 'css'
      send_data result[:css],
                type: 'text/css',
                disposition: "attachment; filename=\"#{config.prefix.presence || 'nanocss'}.css\""
    else
      zip_data = ZipAssemblerService.call(config, result[:css], format)
      send_data zip_data,
                type: 'application/zip',
                disposition: "attachment; filename=\"#{config.prefix.presence || 'nanocss'}.zip\""
    end
  end

  def css
    if params[:theme].present?
      config = ThemeConfiguration.from_base64(params[:theme])
    else
      config = ThemeConfiguration.new(theme_params.presence || {})
    end
    
    scope = params[:preview] == 'true' ? '#preview-canvas' : nil
    result = ScssCompilerService.call(config, scope: scope)
    css = result[:css] || ""
    
    render plain: css, content_type: "text/css"
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
      :margin_md, :space_md, :wrap_in_layer, excluded_components: []
    )
  end
end
