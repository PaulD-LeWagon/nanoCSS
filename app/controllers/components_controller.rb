class ComponentsController < ApplicationController
  def index
    # UC-005 AC2: Use the currently active namespace prefix from params or default to 'nanocss'
    @prefix = params[:prefix].presence || "nanocss"
    
    # We compile the baseline CSS using just the prefix out-of-the-box defaults to render the components correctly
    @config = ThemeConfiguration.new(prefix: @prefix)
    result = ScssCompilerService.call(@config)
    @css = result[:css] || ""
  end

  def test_page
    @prefix = params[:prefix].presence || "nanocss"
    
    # We compile the baseline CSS using just the prefix out-of-the-box defaults to render the components correctly
    @config = ThemeConfiguration.new(prefix: @prefix)
    result = ScssCompilerService.call(@config)
    @css = result[:css] || ""
  end
end
