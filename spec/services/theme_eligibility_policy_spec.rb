# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe ThemeEligibilityPolicy, type: :service do
  it 'admits metadata satisfying required theme keywords' do
    theme = build(:theme, rules: { 'required_keywords' => ['disco'] })

    result = described_class.call(theme: theme, metadata: { title: 'Disco Classics' })

    expect(result).to have_attributes(status: :eligible)
  end

  it 'rejects metadata matching a blocked keyword' do
    theme = build(:theme, rules: { 'blocked_keywords' => ['explicit'] })

    result = described_class.call(theme: theme, metadata: { title: 'Explicit Version' })

    expect(result).to have_attributes(status: :rejected, reason: /blocked/)
  end

  it 'sends missing metadata to host review' do
    theme = build(:theme, rules: { 'required_keywords' => ['disco'] })

    result = described_class.call(theme: theme, metadata: nil)

    expect(result).to have_attributes(status: :review)
  end

  it 'admits a song matching any host-provided artist or song example' do
    theme = build(:theme, rules: { 'match_any_keywords' => ['adele', 'someone like you'] })

    result = described_class.call(theme: theme, metadata: { title: 'Easy On Me - Adele Karaoke' })

    expect(result).to have_attributes(status: :eligible)
  end

  it 'sends an unfamiliar song to host review when examples are present' do
    theme = build(:theme, rules: { 'match_any_keywords' => ['adele'] })

    result = described_class.call(theme: theme, metadata: { title: 'Dream On - Aerosmith' })

    expect(result).to have_attributes(status: :review, reason: /theme example/)
  end

  it 'does not reject an unrestricted theme' do
    result = described_class.call(theme: build(:theme), metadata: nil)

    expect(result).to have_attributes(status: :eligible)
  end
end
# rubocop:enable Metrics/BlockLength
