# frozen_string_literal: true

require 'rails_helper'

# The validation matrix is intentionally kept together as one contract.
# rubocop:disable Metrics/BlockLength
RSpec.describe EventThemeApplication, type: :model do
  it { is_expected.to belong_to(:event) }
  it { is_expected.to belong_to(:theme) }

  it 'knows whether its theme window is active' do
    event = create(:event, starts_at: 1.hour.ago, ends_at: 1.hour.from_now)
    application = create(:event_theme_application, event: event, starts_at: event.starts_at, ends_at: event.ends_at)

    expect(application.active_at?).to be(true)
    expect(application.active_at?(2.hours.from_now)).to be(false)
  end

  it 'requires the theme to belong to the event venue' do
    event = create(:event)
    application = build(:event_theme_application, event: event, theme: create(:theme))

    expect(application).not_to be_valid
    expect(application.errors[:theme]).to include('must belong to the same venue as the event')
  end

  it 'supports a bounded event-time window' do
    event = create(:event)
    starts_at = event.starts_at + 1.hour
    ends_at = event.ends_at - 1.hour
    application = build(:event_theme_application, event: event, starts_at: starts_at, ends_at: ends_at)

    expect(application).to be_valid
  end

  it 'rejects a partial or out-of-bounds time window' do
    event = create(:event)
    partial = build(:event_theme_application, event: event, starts_at: event.starts_at, ends_at: nil)
    starts_at = event.starts_at - 1.hour
    outside = build(:event_theme_application, event: event, starts_at: starts_at, ends_at: event.starts_at)

    expect(partial).not_to be_valid
    expect(outside).not_to be_valid
  end

  it 'rejects overlapping theme windows on the same event' do
    event = create(:event)
    create(:event_theme_application, event: event, starts_at: event.starts_at, ends_at: event.starts_at + 1.hour)
    overlapping = build(
      :event_theme_application,
      event: event,
      starts_at: event.starts_at + 30.minutes,
      ends_at: event.starts_at + 2.hours
    )

    expect(overlapping).not_to be_valid
    expect(overlapping.errors[:base]).to include('a theme time window cannot overlap another theme on the event')
  end

  it 'allows touching windows and rejects overlap with an all-event theme' do
    event = create(:event)
    create(:event_theme_application, event: event, starts_at: event.starts_at, ends_at: event.starts_at + 1.hour)
    touching = build(
      :event_theme_application,
      event: event,
      starts_at: event.starts_at + 1.hour,
      ends_at: event.starts_at + 2.hours
    )
    expect(touching).to be_valid

    whole_event = create(:event)
    create(:event_theme_application, event: whole_event)
    expect(
      build(
        :event_theme_application,
        event: whole_event,
        starts_at: whole_event.starts_at,
        ends_at: whole_event.starts_at + 1.hour
      )
    ).not_to be_valid
  end
end
# rubocop:enable Metrics/BlockLength
