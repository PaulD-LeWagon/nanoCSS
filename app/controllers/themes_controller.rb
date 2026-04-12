class ThemesController < ApplicationController
  # Download is a stateless read operation — no server mutation occurs.
  # The CSRF token can fail when formaction overrides the original form target.
  skip_forgery_protection only: :download
  def index
    @presets = [
      { name: "Corporate", primary: "#1e40af", secondary: "#6366f1", tertiary: "#06b6d4", default: true },
      { name: "Playful", primary: "#f43f5e", secondary: "#a855f7", tertiary: "#f97316" },
      { name: "Minimalist", primary: "#000000", secondary: "#404040", tertiary: "#737373" }
    ]
    # Pre-compile default CSS so the landing page preview works
    @config = ThemeConfiguration.new
    result = ScssCompilerService.call(@config)
    @css = result[:css] || ""
  end

  def show
    if params[:theme].present?
      @config = ThemeConfiguration.from_base64(params[:theme])
    else
      @config = ThemeConfiguration.new
    end

    # Pre-compile the CSS for the initial page render
    result = ScssCompilerService.call(@config)
    @css = result[:css] || ""
    
    @complementary = ColourHarmonyService.call(@config.primary, harmony_type: :complementary)
    @analogous = ColourHarmonyService.call(@config.primary, harmony_type: :analogous)
    @triadic = ColourHarmonyService.call(@config.primary, harmony_type: :triadic)
  end

  def preview
    @config = ThemeConfiguration.new(theme_params)
    result = ScssCompilerService.call(@config)
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

    zip_data = ZipAssemblerService.call(config, result[:css])

    send_data zip_data,
              type: 'application/zip',
              disposition: "attachment; filename=\"#{config.prefix.presence || 'nanocss'}.zip\""
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
