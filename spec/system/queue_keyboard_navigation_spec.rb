# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe 'Queue keyboard navigation', type: :system do
  let(:venue) { create(:venue) }
  let(:owner) { venue.owner }
  let(:event) { create(:event, venue: venue, status: :live, starts_at: 1.hour.ago, ends_at: 2.hours.from_now) }

  before do
    driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1000]
    create(:performance, venue: venue, event: event)
    visit new_user_session_path
    fill_in 'Email Address', with: owner.email
    fill_in 'Password', with: 'SecurePassword123!'
    click_button 'Sign In'
  end

  it 'keeps every queue tab in sequential tab order and supports arrow navigation' do
    visit venue_event_queue_path(venue.slug, event_slug: event.slug)

    expect(page).to have_css('.songs-tab[role="tab"]', minimum: 4)
    tab_indexes = page.evaluate_script('Array.from(document.querySelectorAll(".songs-tab")).map((tab) => tab.tabIndex)')
    expect(tab_indexes).to all(eq(0))
    expect(find('#event-tab')['aria-controls']).to eq('event-panel')

    queue_tab = find('#queue-tab')
    queue_tab.click
    queue_tab.send_keys(:tab)

    expect(page.evaluate_script('document.activeElement.id')).to eq('add-tab')

    find('#add-tab').send_keys(:arrow_right)

    expect(page.evaluate_script('document.activeElement.id')).to eq('themes-tab')
    expect(find('#themes-tab')['aria-selected']).to eq('true')
    expect(find('#themes-panel', visible: :all)[:hidden]).to be_nil
  end
end
# rubocop:enable Metrics/BlockLength
