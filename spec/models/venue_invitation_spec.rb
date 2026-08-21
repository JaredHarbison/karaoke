require 'rails_helper'

RSpec.describe VenueInvitation, type: :model do
  let(:venue) { create(:venue) }
  let(:inviter) { venue.owner }

  it 'accepts a pending invitation for the invited email' do
    user = create(:user, email: 'host@example.com')
    invitation = described_class.create!(venue: venue, invited_by: inviter, email: user.email)

    expect { invitation.accept!(user) }.to change { venue.reload.hosts.to_a }.from([]).to([user])
    expect(invitation.reload).to be_present
    expect(invitation.accepted_at).to be_present
  end

  it 'rejects a different account email' do
    invitation = described_class.create!(venue: venue, invited_by: inviter, email: 'host@example.com')
    other_user = create(:user, email: 'someone-else@example.com')

    expect { invitation.accept!(other_user) }.to raise_error(ActiveRecord::RecordInvalid)
    expect(invitation.reload.accepted_at).to be_nil
  end
end
