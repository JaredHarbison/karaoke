# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe 'Help', type: :request do
  let(:venue) { create(:venue) }
  let(:owner) { venue.owner }
  let(:host) { create(:user).tap { |user| venue.add_host(user) } }
  let(:performer) { create(:user) }

  it 'renders general and venue-operator guides for an owner' do
    sign_in owner

    get '/help'

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Help', 'Using the karaoke queue', 'Creating and editing recurring events')
  end

  it 'renders venue-operator guides for an assigned host' do
    sign_in host

    get '/help'

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Delegating temporary hosting')
  end

  it 'renders only general guides for a performer' do
    sign_in performer

    get '/help'

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Using the karaoke queue')
    expect(response.body).not_to include('Delegating temporary hosting')
  end

  it 'requires authentication' do
    get '/help'

    expect(response).to redirect_to('/users/sign_in')
  end
end
# rubocop:enable Metrics/BlockLength
