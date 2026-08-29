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

RSpec.describe 'Account page', type: :request do
  include Devise::Test::IntegrationHelpers

  it 'uses the shared account form and permits a signed-in user to update their name' do
    user = create(:user)
    sign_in user

    get edit_user_registration_path

    expect(response).to be_successful
    expect(response.body).to include("id='account-heading'", 'password-strength', 'user_first_name', 'user_last_name')

    put user_registration_path, params: {
      user: {
        first_name: 'Updated',
        last_name: 'Performer',
        email: user.email,
        current_password: 'SecurePassword123!'
      }
    }

    expect(user.reload).to have_attributes(first_name: 'Updated', last_name: 'Performer')
  end
end
