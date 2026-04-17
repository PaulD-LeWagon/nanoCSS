class ThemeConfiguration
  include ActiveModel::Model

  attr_accessor :primary, :secondary, :tertiary, :prefix,
                :font_heading, :font_subtitle, :font_body, :font_code,
                :base_typography, :base_space, :base_margin,
                :base_radius, :base_border_width,
                :text_shadow, :drop_shadow, :tier, :mode,
                :margin_md, :space_md,
                :excluded_components, :wrap_in_layer

  GOOGLE_FONTS_WHITELIST = ['Inter', 'Roboto', 'Oswald', 'Fira Code', 'Source Code Pro', 'JetBrains Mono', 'Merriweather'].freeze
  VALID_COMPONENTS = ['modal', 'carousel', 'card', 'hero', 'dropdown', 'group', 'loader', 'nav', 'badge', 'tag', 'breadcrumb', 'pagination', 'tabs', 'btn', 'tooltip'].freeze

  validates :primary, :secondary, :tertiary, format: { with: /\A#[0-9a-fA-F]{6}\z/, message: "is invalid" }, allow_blank: true
  validates :prefix, format: { with: /\A[a-z][a-z0-9-]*[a-z0-9]\z/, message: "is invalid" }, allow_blank: true
  validates :font_heading, :font_subtitle, :font_body, :font_code, inclusion: { in: GOOGLE_FONTS_WHITELIST, message: "is not a recognised Google Font" }, allow_blank: true
  validate :validate_excluded_components

  def initialize(attributes = {})
    super
    @excluded_components ||= []
    @wrap_in_layer = false if @wrap_in_layer.nil?
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
    
    # $prefix controls output naming (class names, CSS custom property names).
    # All SCSS variable overrides MUST use $nanocss-* to correctly override
    # the !default declarations in _variables.scss.
    vars << "$prefix: '#{prefix}';" if prefix.present?
    
    # Brand colours
    vars << "$nanocss-primary: #{primary};" if primary.present?
    vars << "$nanocss-secondary: #{secondary};" if secondary.present?
    vars << "$nanocss-tertiary: #{tertiary};" if tertiary.present?
    
    # Typography slots
    vars << "$nanocss-font-heading: \"#{font_heading}\";" if font_heading.present?
    vars << "$nanocss-font-subtitle: \"#{font_subtitle}\";" if font_subtitle.present?
    vars << "$nanocss-font-body: \"#{font_body}\";" if font_body.present?
    vars << "$nanocss-font-code: \"#{font_code}\";" if font_code.present?
    
    # Base Anchors
    vars << "$nanocss-base-typography: #{base_typography};" if base_typography.present?
    vars << "$nanocss-base-space: #{base_space};" if base_space.present?
    vars << "$nanocss-base-margin: #{base_margin};" if base_margin.present?
    vars << "$nanocss-base-radius: #{base_radius};" if base_radius.present?
    vars << "$nanocss-base-border-width: #{base_border_width};" if base_border_width.present?
    
    # Shadow matrices
    vars << "$nanocss-text-shadow: #{text_shadow};" if text_shadow.present?
    vars << "$nanocss-drop-shadow: #{drop_shadow};" if drop_shadow.present?
    
    # Advanced mode: decoupled overrides
    if mode == 'advanced'
      vars << "$nanocss-margin-md: #{margin_md};" if margin_md.present?
      vars << "$nanocss-space-md: #{space_md};" if space_md.present?
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

  private

  def validate_excluded_components
    if excluded_components.present? && !excluded_components.is_a?(Array)
      errors.add(:excluded_components, "must be an array")
    elsif excluded_components.present? && (excluded_components - VALID_COMPONENTS).any?
      errors.add(:excluded_components, "contains invalid component names")
    end
  end
end
