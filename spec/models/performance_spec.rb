# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Performance, type: :model do
  it 'uses the existing queue table as the event-specific record' do
    performance = create(:performance, event: nil)

    expect(performance).to be_a(Performance)
    expect(Performance.find(performance.id)).to be_a(Performance)
    expect(Performance.table_name).to eq('songs')
  end

  it 'links each event queue entry to one canonical song identity' do
    identity = create(:canonical_song, provider_video_id: 'performance-video')
    performance = create(:performance, song_identity: identity)

    expect(performance.song).to eq(identity)
    expect(identity.performances.map(&:id)).to contain_exactly(performance.id)
  end

  it 'owns theme admission assignment and review transitions' do
    performance = build(:performance)
    performance.assign_theme_admission(application: nil, status: 'review', reason: 'theme mismatch')

    expect(performance).to have_attributes(theme_admission_status: 'review', theme_admission_reason: 'theme mismatch')

    reviewer = create(:user)
    performance.save!
    performance.review_theme!(status: 'rejected', reason: 'host rejected theme admission', reviewer: reviewer)

    expect(performance.reload).to have_attributes(
      theme_admission_status: 'rejected',
      theme_reviewed_by: reviewer
    )
  end

  it 'owns release of unresolved theme review after the application ends' do
    event = create(:event, starts_at: 2.hours.ago)
    theme = create(:theme, venue: event.venue)
    application = create(
      :event_theme_application,
      event: event,
      theme: theme,
      starts_at: event.starts_at,
      ends_at: 1.minute.ago
    )
    performance = create(
      :performance,
      event: event,
      venue: event.venue,
      theme_application: application,
      theme_admission_status: 'review'
    )

    expect(performance.release_theme!).to be(true)
    expect(performance.reload.theme_admission_status).to eq('released')
  end
end
