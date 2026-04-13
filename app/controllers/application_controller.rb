class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Compile a default nanocss payload for every page so the layout can inject it
  # into <head>. This means the app styles itself with its own framework — dogfooding
  # at the architecture level. The result is memoized per-request (not cached globally
  # so that a live server restart picks up SCSS changes).
  # Traces: design/PRD.md FR-001, FR-005; design/UI_COMPONENTS.md §2 Design Tokens
  before_action :compile_default_nanocss

  private

  def compile_default_nanocss
    @nanocss_css ||= begin
      result = ScssCompilerService.call(ThemeConfiguration.new)
      result[:css] || ""
    end
  end
end
