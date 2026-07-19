module ApplicationHelper
  def auth_return_to
    candidate = session[:user_return_to] || session['user_return_to'] || params[:return_to]
    return unless candidate.present?

    candidate = candidate.to_s
    candidate if candidate.start_with?('/') && !candidate.start_with?('//')
  end

  def auth_context
    path = auth_return_to
    return 'Sign in to continue.' unless path.present?

    venue_slug = path.match(%r{\A/([^/]+)/songs})&.captures&.first
    venue = Venue.find_by(slug: venue_slug) if venue_slug.present?

    if venue
      "Sign in to join the queue at #{venue.name}."
    else
      'Sign in to continue where you left off.'
    end
  end

  def auth_link_options
    auth_return_to.present? ? { return_to: auth_return_to } : {}
  end
end
