class ApplicationController < ActionController::Base
  before_action :set_current_venue
  before_action :set_current_user
  before_action :require_venue_for_songs
  
  rescue_from ActiveRecord::RecordNotFound, with: :render_404
  
  private
  
  def set_current_venue
    # Extract venue_slug from URL path (e.g., /joes-bar/songs)
    venue_slug = params[:venue_slug]
    
    if venue_slug.present?
      Current.venue = Venue.find_by(slug: venue_slug)
      session[:venue_slug] = venue_slug if Current.venue
    elsif session[:venue_slug].present?
      # Fallback to session if not in path (for non-scoped routes)
      Current.venue = Venue.find_by(slug: session[:venue_slug])
    end
  end
  
  def set_current_user
    Current.user = current_user if user_signed_in?
  end
  
  def require_venue_for_songs
    # Only enforce for songs routes
    return unless params[:controller].start_with?('songs') || params[:controller] == 'admins'
    
    unless Current.venue.present?
      redirect_to discover_venues_path, alert: 'Venue not found. Please select a venue to continue.'
    end
  end
  
  def require_admin!
    unless Current.user.present? && Current.venue.present? && Current.venue.is_admin?(Current.user)
      redirect_to venue_songs_path(Current.venue.slug), alert: 'You do not have permission to access this page.'
    end
  end
  
  def require_owner!
    unless Current.user.present? && Current.venue.present? && Current.venue.owner_id == Current.user.id
      redirect_to venue_songs_path(Current.venue.slug), alert: 'Only the venue owner can access this page.'
    end
  end
  
  def render_404
    render file: "#{Rails.root}/public/404.html", status: :not_found, layout: false
  end
end
