# Traces: design/BACKLOG.md UC-061, UC-062
# Traces: design/SYSTEM_DESIGN.md §4 (GET /showcase)
#
# Uses a dedicated layout (layouts/showcase.html.erb) that omits application.css
# so the page renders against the default nanoCSS framework stylesheet only —
# no dark chrome bleed-through from the Obsidian app shell.
class ShowcaseController < ApplicationController
  layout "showcase"

  def show
    @prefix = "nanocss"
  end
end
