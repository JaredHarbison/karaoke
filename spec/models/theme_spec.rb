# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe Theme, type: :model do
  it { is_expected.to belong_to(:venue) }
  it { is_expected.to have_many(:event_theme_applications).dependent(:destroy) }
  it { is_expected.to have_many(:events).through(:event_theme_applications) }
  it { is_expected.to validate_presence_of(:name) }

  it 'keeps theme names unique within a venue' do
    theme = create(:theme)
    duplicate = build(:theme, venue: theme.venue, name: theme.name)

    expect(duplicate).not_to be_valid
  end

  it 'normalizes host-authored keyword rules into the rules document' do
    theme = build(:theme, required_keywords_text: ' Disco, classics, disco ', blocked_keywords_text: ' Explicit ')

    expect(theme).to be_valid
    expect(theme.rules).to eq(
      'required_keywords' => %w[disco classics],
      'blocked_keywords' => ['explicit']
    )
  end

  it 'stores host-facing examples as an any-match rule' do
    theme = build(:theme, match_examples_text: 'Adele, Someone Like You, Adele')

    expect(theme).to be_valid
    expect(theme.rules).to eq('match_any_keywords' => ['adele', 'someone like you'])
  end

  it 'rejects unsupported rule keys' do
    theme = build(:theme, rules: { 'artist_allowlist' => ['Dua Lipa'] })

    expect(theme).not_to be_valid
    expect(theme.errors[:rules]).to include(/unsupported keys/)
  end
end
# rubocop:enable Metrics/BlockLength
