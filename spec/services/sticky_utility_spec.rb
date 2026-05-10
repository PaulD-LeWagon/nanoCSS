require 'rails_helper'

# Traces: design/BACKLOG.md UC-059
RSpec.describe 'UC-059: .{prefix}-sticky utility class' do
  let(:config) { ThemeConfiguration.new }

  it 'AC1: compiled CSS contains position: sticky for the default prefix' do
    result = ScssCompilerService.call(config)
    expect(result[:error]).to be_nil
    expect(result[:css]).to include('.nanocss-sticky')
    expect(result[:css]).to include('position: sticky')
  end

  it 'AC1: uses $nanocss-z-sticky variable for z-index (value 1020)' do
    result = ScssCompilerService.call(config)
    expect(result[:css]).to match(/\.nanocss-sticky\s*\{[^}]*z-index:\s*1020/)
  end

  it 'AC1: respects custom prefix in sticky class name' do
    config.prefix = 'myapp'
    result = ScssCompilerService.call(config)
    expect(result[:css]).to include('.myapp-sticky')
    expect(result[:css]).not_to include('.nanocss-sticky')
  end
end
