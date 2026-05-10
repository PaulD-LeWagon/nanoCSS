# Traces: design/BACKLOG.md UC-061, UC-062
# Traces: design/SYSTEM_DESIGN.md §4 (GET /showcase)
class ShowcaseController < ApplicationController
  def show
    @suppress_app_nav = true
    @prefix = "nanocss"
  end
end
