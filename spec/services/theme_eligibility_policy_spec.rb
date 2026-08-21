# frozen_string_literal: true

require 'rails_helper'

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

  it 'does not reject an unrestricted theme' do
    result = described_class.call(theme: build(:theme), metadata: nil)

    expect(result).to have_attributes(status: :eligible)
  end
end
