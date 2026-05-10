require 'rails_helper'

# Traces: design/BACKLOG.md UC-060
RSpec.describe 'UC-060: Accordion component' do
  let(:config) { ThemeConfiguration.new }
  let(:css) { ScssCompilerService.call(config)[:css] }

  it 'AC8: compiled CSS includes .nanocss-accordion wrapper class' do
    expect(css).to include('.nanocss-accordion')
  end

  it 'AC8: compiled CSS includes .nanocss-accordion--independent modifier' do
    expect(css).to include('.nanocss-accordion--independent')
  end

  it 'AC8: prefix is applied to accordion class (custom prefix test)' do
    cfg = ThemeConfiguration.new(prefix: 'myapp')
    result = ScssCompilerService.call(cfg)[:css]
    expect(result).to include('.myapp-accordion')
    expect(result).not_to include('.nanocss-accordion')
  end
end
