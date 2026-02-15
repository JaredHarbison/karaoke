module AuthHelpers
  # Helpers for authentication and authorization testing
  
  def login_as_user(user)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  def set_current_venue(venue)
    Current.venue = venue
  end

  def set_current_user(user)
    Current.user = user
  end

  def clear_current_context
    Current.venue = nil
    Current.user = nil
  end

  def venue_path_for(venue, path = '')
    "/#{venue.slug}#{path}"
  end

  def admin_requires_venue_and_user?(controller_action)
    # Helper to test if an action properly requires admin authorization
    # Usage: expect { get :action, params: {...} }.to require_admin
    # This is a placeholder - specific implementations per controller in their specs
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :controller
  config.include AuthHelpers, type: :request
  config.include AuthHelpers, type: :system
  
  # Use Devise test helpers for request/integration/system specs
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Devise::Test::IntegrationHelpers, type: :system
end
