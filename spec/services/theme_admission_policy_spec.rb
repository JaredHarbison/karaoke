# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ThemeAdmissionPolicy, type: :service do
  let(:venue) { create(:venue) }
  let(:event) { create(:event, venue: venue, starts_at: 1.hour.ago, ends_at: 1.hour.from_now) }

  it 'marks a song not applicable when no theme is active' do
    result = described_class.call(event: event, metadata: { title: 'Any song' })

    expect(result).to have_attributes(status: :not_applicable, application: nil)
  end

  it 'admits metadata that satisfies the active theme' do
    theme = create(:theme, venue: venue, rules: { 'required_keywords' => ['disco'] })
    application = create(:event_theme_application, event: event, theme: theme)

    result = described_class.call(event: event, metadata: { title: 'Disco Classics' })

    expect(result).to have_attributes(status: :eligible, application: application)
  end

  it 'holds theme-ineligible metadata for host review' do
    theme = create(:theme, venue: venue, rules: { 'blocked_keywords' => ['explicit'] })
    create(:event_theme_application, event: event, theme: theme)

    result = described_class.call(event: event, metadata: { title: 'Explicit Version' })

    expect(result).to have_attributes(status: :review, reason: /blocked/)
  end

  it 'holds incomplete metadata for host review' do
    theme = create(:theme, venue: venue, rules: { 'required_keywords' => ['disco'] })
    create(:event_theme_application, event: event, theme: theme)

    result = described_class.call(event: event, metadata: nil)

    expect(result.status).to eq(:review)
  end
end
