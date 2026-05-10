require 'rails_helper'

# Traces: design/BACKLOG.md UC-062 AC1
# Asserts no inline style= attributes in app/views/showcase/.
# A <style> block for page geometry (grid, breakpoints) is permitted —
# the restriction targets component-level overrides, not layout geometry.
RSpec.describe 'Showcase lint: no inline style= attributes', type: :request do
  it 'app/views/showcase/ contains no style= attribute declarations' do
    showcase_views = Dir.glob(Rails.root.join('app/views/showcase/**/*.erb'))
    expect(showcase_views).not_to be_empty, 'Expected at least one showcase view file'
    showcase_views.each do |file|
      content = File.read(file)
      expect(content).not_to match(/\bstyle\s*=\s*['"]/),
        "#{file} contains a style= attribute — all component styling must come from nanoCSS classes"
    end
  end
end
