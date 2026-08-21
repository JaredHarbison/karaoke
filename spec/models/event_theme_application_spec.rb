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
    application = build(:event_theme_application, starts_at: 1.hour.from_now, ends_at: 2.hours.from_now)

    expect(application).to be_valid
  end
end
