# frozen_string_literal: true

require 'rails_helper'

# The release contract covers both automatic release and explicit rejection.
# rubocop:disable Metrics/BlockLength
RSpec.describe ThemeAdmissionRelease, type: :service do
  let(:event) { create(:event, starts_at: 1.hour.ago, ends_at: 1.hour.from_now) }
  let(:theme) { create(:theme, venue: event.venue) }

  it 'releases unresolved review entries after the theme window ends' do
    application = create(
      :event_theme_application,
      event: event,
      theme: theme,
      starts_at: event.starts_at,
      ends_at: 1.minute.ago
    )
    song = create(
      :performance,
      venue: event.venue,
      event: event,
      theme_application: application,
      theme_admission_status: 'review'
    )

    expect(described_class.call(event: event)).to eq(1)
    expect(song.reload).to have_attributes(theme_admission_status: 'released')
  end

  it 'does not release an explicit rejection' do
    application = create(
      :event_theme_application,
      event: event,
      theme: theme,
      starts_at: event.starts_at,
      ends_at: 1.minute.ago
    )
    song = create(
      :performance,
      venue: event.venue,
      event: event,
      theme_application: application,
      theme_admission_status: 'rejected'
    )

    expect(described_class.call(event: event)).to eq(0)
    expect(song.reload.theme_admission_status).to eq('rejected')
  end

  it 'does not release content-policy review after the theme window ends' do
    application = create(
      :event_theme_application,
      event: event,
      theme: theme,
      starts_at: event.starts_at,
      ends_at: 1.minute.ago
    )
    song = create(
      :performance,
      venue: event.venue,
      event: event,
      theme_application: application,
      theme_admission_status: 'review',
      theme_admission_reason: 'content policy: explicit lyrics are not allowed at this venue'
    )

    expect(described_class.call(event: event)).to eq(0)
    expect(song.reload.theme_admission_status).to eq('review')
  end
end
# rubocop:enable Metrics/BlockLength
