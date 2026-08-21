# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventThemeApplication, type: :model do
  it { is_expected.to belong_to(:event) }
  it { is_expected.to belong_to(:theme) }

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
    partial = build(:event_theme_application, event: event, starts_at: event.starts_at)
    starts_at = event.starts_at - 1.hour
    outside = build(:event_theme_application, event: event, starts_at: starts_at, ends_at: event.starts_at)

    expect(partial).not_to be_valid
    expect(outside).not_to be_valid
  end
end
