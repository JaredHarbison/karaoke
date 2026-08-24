# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Authentication pages', type: :request do
  it 'provides a labeled main landmark on sign in' do
    get new_user_session_path

    expect(response).to be_successful
    expect(response.body).to include("class='auth-page'", "id='sign-in-heading'")
  end

  it 'provides a labeled main landmark on sign up' do
    get new_user_registration_path

    expect(response).to be_successful
    expect(response.body).to include("class='auth-page'", "id='sign-up-heading'")
  end
end
