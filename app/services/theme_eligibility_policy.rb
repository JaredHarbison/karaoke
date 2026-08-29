# frozen_string_literal: true

# Evaluates reusable theme rules without making uncertain metadata decisions.
class ThemeEligibilityPolicy
  Result = Struct.new(:status, :reason, keyword_init: true)

  def self.call(theme:, metadata:)
    new(theme: theme, metadata: metadata).call
  end

  def initialize(theme:, metadata:)
    @rules = theme.rules || {}
    @metadata = metadata
  end

  def call
    return eligible('theme has no restrictions') if unrestricted?
    return review('metadata is unavailable') unless @metadata
    return review('metadata text is unavailable') if searchable_text.blank?
    return reject('metadata matches a blocked theme keyword') if blocked_keyword?
    return review('metadata does not match a theme example') if missing_match_example?
    return reject('metadata does not satisfy required theme keywords') if missing_required_keyword?

    eligible('metadata satisfies theme rules')
  end

  private

  def unrestricted?
    match_examples.empty? && required_keywords.empty? && blocked_keywords.empty?
  end

  def searchable_text
    [@metadata[:title], @metadata[:description], @metadata[:category]].compact.join(' ').downcase
  end

  def required_keywords
    Array(@rules['required_keywords'] || @rules[:required_keywords]).map(&:to_s).reject(&:blank?)
  end

  def blocked_keywords
    Array(@rules['blocked_keywords'] || @rules[:blocked_keywords]).map(&:to_s).reject(&:blank?)
  end

  def match_examples
    Array(@rules['match_any_keywords'] || @rules[:match_any_keywords]).map(&:to_s).reject(&:blank?)
  end

  def blocked_keyword?
    blocked_keywords.any? { |keyword| searchable_text.include?(keyword.downcase) }
  end

  def missing_required_keyword?
    required_keywords.any? { |keyword| !searchable_text.include?(keyword.downcase) }
  end

  def missing_match_example?
    match_examples.any? && match_examples.none? { |example| searchable_text.include?(example.downcase) }
  end

  def eligible(reason)
    Result.new(status: :eligible, reason: reason)
  end

  def reject(reason)
    Result.new(status: :rejected, reason: reason)
  end

  def review(reason)
    Result.new(status: :review, reason: reason)
  end
end
