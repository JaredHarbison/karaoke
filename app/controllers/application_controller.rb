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

  def after_sign_in_path_for(resource)
    invitation_path = accept_pending_invitation(resource)
    return invitation_path if invitation_path

    safe_auth_path(stored_location_for(resource)) || root_path
  end

  def after_sign_up_path_for(resource)
    invitation_path = accept_pending_invitation(resource)
    return invitation_path if invitation_path

    safe_auth_path(session.delete(:user_return_to)) || safe_auth_path(params[:return_to]) || root_path
  end
  
  def require_venue_for_songs
    # Only enforce for songs routes
    return unless params[:controller].start_with?('songs')
    
    unless Current.venue.present?
      redirect_to discover_venues_path, alert: 'Venue not found. Please select a venue to continue.'
    end
  end
  
  def require_admin!
    unless Current.venue.present? && Current.venue.is_admin?(Current.user)
      redirect_to (Current.venue ? venue_songs_path(Current.venue.slug) : discover_venues_path), alert: 'You do not have permission to access this page.'
    end
  end

  def require_owner!
    unless Current.venue.present? && Current.venue.owner?(Current.user)
      redirect_to (Current.venue ? venue_songs_path(Current.venue.slug) : discover_venues_path), alert: 'Only the venue owner can access this page.'
    end
  end
  
  def render_404
    render file: "#{Rails.root}/public/404.html", status: :not_found, layout: false
  end

  def accept_pending_invitation(user)
    token = session.delete(:pending_venue_invitation_token)
    return unless token.present?

    invitation = VenueInvitation.pending.find_by(token: token)
    return unless invitation

    invitation.accept!(user)
    venue_songs_path(invitation.venue.slug)
  rescue ActiveRecord::RecordInvalid
    flash[:alert] = 'Your account email does not match the host invitation.'
  end

  def safe_auth_path(path)
    value = path.to_s
    value if value.start_with?('/') && !value.start_with?('//')
  end
end
