# frozen_string_literal: true

# Reusable theme definition owned by one venue.
class Theme < ApplicationRecord
  RULE_KEYS = %w[match_any_keywords required_keywords blocked_keywords].freeze

  belongs_to :venue
  has_many :event_theme_applications, dependent: :destroy
  has_many :events, through: :event_theme_applications

  validates :name, presence: true, uniqueness: { scope: :venue_id }
  validate :rules_are_supported
  before_validation :sync_rules_from_form

  def required_keywords_text
    @required_keywords_text ||= keywords_text_for('required_keywords')
  end

  def match_examples_text
    @match_examples_text ||= keywords_text_for('match_any_keywords').presence || required_keywords_text
  end

  def blocked_keywords_text
    @blocked_keywords_text ||= keywords_text_for('blocked_keywords')
  end

  def required_keywords_text=(value)
    @required_keywords_text = value
    @rule_fields_touched = true
  end

  def match_examples_text=(value)
    @match_examples_text = value
    @rule_fields_touched = true
  end

  def blocked_keywords_text=(value)
    @blocked_keywords_text = value
    @rule_fields_touched = true
  end

  private

  def rules_are_supported
    return errors.add(:rules, 'must be a JSON object') unless rules.is_a?(Hash)

    unknown_keys = rules.stringify_keys.keys - RULE_KEYS
    return if unknown_keys.empty?

    errors.add(:rules, "contains unsupported keys: #{unknown_keys.join(', ')}")
  end

  def sync_rules_from_form
    return unless @rule_fields_touched

    match_rules = if @match_examples_text.nil?
                    { 'required_keywords' => parse_keywords(@required_keywords_text) }
                  else
                    { 'match_any_keywords' => parse_keywords(@match_examples_text) }
                  end
    self.rules = match_rules.merge(
      'blocked_keywords' => parse_keywords(@blocked_keywords_text)
    ).reject { |_key, keywords| keywords.empty? }
  end

  def parse_keywords(value)
    value.to_s.split(',').map { |keyword| keyword.strip.downcase }.reject(&:blank?).uniq
  end

  def keywords_text_for(key)
    Array(rules&.[](key) || rules&.[](key.to_sym)).join(', ')
  end
end
