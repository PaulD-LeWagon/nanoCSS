class ThemeConfiguration
  include ActiveModel::Model

  attr_accessor :primary, :secondary, :tertiary, :prefix,
                :font_heading, :font_subtitle, :font_body, :font_code,
                :base_typography, :base_space, :base_margin,
                :base_radius, :base_border_width,
                :text_shadow, :drop_shadow, :tier, :mode,
                :margin_md, :space_md

  validates :primary, :secondary, :tertiary, format: { with: /\A#[0-9a-fA-F]{6}\z/, message: "is invalid" }, allow_blank: true
  validates :prefix, format: { with: /\A[a-z][a-z0-9-]*[a-z0-9]\z/, message: "is invalid" }, allow_blank: true

  def initialize(attributes = {})
    super
    @prefix ||= 'nanocss'
    @primary ||= '#3b82f6'
    @secondary ||= '#8b5cf6'
    @tertiary ||= '#ec4899'
    @mode ||= 'basic'
    @font_heading ||= 'Inter'
    @font_subtitle ||= 'Inter'
    @font_body ||= 'Roboto'
    @font_code ||= 'Fira Code'
    @base_typography ||= '1rem'
    @base_space ||= '0.5rem'
    @base_margin ||= '1.25rem'
    @base_radius ||= '0.25rem'
    @base_border_width ||= '1px'
    @text_shadow ||= '0.25rem 0.25rem 0.5rem rgba(5, 5, 5, 0.5)'
    @drop_shadow ||= '0.5rem 0.5rem 1rem rgba(1, 1, 1, 0.25)'
  end

  def to_scss_variables_string
    vars = []
    
    # Prefix mapping
    vars << "$prefix: '#{prefix}';" if prefix.present?
    
    vars << "$#{prefix}-primary: #{primary};" if primary.present?
    vars << "$#{prefix}-secondary: #{secondary};" if secondary.present?
    vars << "$#{prefix}-tertiary: #{tertiary};" if tertiary.present?
    
    # Typography slots
    vars << "$#{prefix}-font-heading: \"#{font_heading}\";" if font_heading.present?
    vars << "$#{prefix}-font-subtitle: \"#{font_subtitle}\";" if font_subtitle.present?
    vars << "$#{prefix}-font-body: \"#{font_body}\";" if font_body.present?
    vars << "$#{prefix}-font-code: \"#{font_code}\";" if font_code.present?
    
    # Base Anchors
    vars << "$#{prefix}-base-typography: #{base_typography};" if base_typography.present?
    vars << "$#{prefix}-base-space: #{base_space};" if base_space.present?
    vars << "$#{prefix}-base-margin: #{base_margin};" if base_margin.present?
    vars << "$#{prefix}-base-radius: #{base_radius};" if base_radius.present?
    vars << "$#{prefix}-base-border-width: #{base_border_width};" if base_border_width.present?
    
    # Matrix parsing
    vars << "$#{prefix}-text-shadow: #{text_shadow};" if text_shadow.present?
    vars << "$#{prefix}-drop-shadow: #{drop_shadow};" if drop_shadow.present?
    
    # Advanced logic: decoupling
    if mode == 'advanced'
      vars << "$#{prefix}-margin-md: #{margin_md};" if margin_md.present?
      vars << "$#{prefix}-space-md: #{space_md};" if space_md.present?
    end

    vars.join("\n")
  end

  def to_base64
    require 'base64'
    require 'json'
    Base64.urlsafe_encode64(self.as_json.to_json)
  end

  def self.from_base64(encoded_string)
    require 'base64'
    require 'json'
    begin
      json = Base64.urlsafe_decode64(encoded_string)
      attrs = JSON.parse(json)
      new(attrs)
    rescue StandardError
      new # return default
    end
  end
end
