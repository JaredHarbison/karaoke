class ApplicationController < ActionController::Base
  before_action :set_current_venue
  before_action :set_current_user
  
  private
  
  def set_current_venue
    # For now, use a simple approach: check for venue_slug param or subdomain
    # You can refine this to use subdomains in production: request.subdomain
    venue_slug = params[:venue_slug] || session[:venue_slug]
    
    if venue_slug.present?
      Current.venue = Venue.find_by(slug: venue_slug)
      session[:venue_slug] = venue_slug if Current.venue
    end
  end
  
  def set_current_user
    Current.user = current_user if user_signed_in?
  end
end
