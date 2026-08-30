# frozen_string_literal: true

# Resolves permanent venue and expiring event presence bearer URLs.
class PresenceController < ApplicationController
  skip_before_action :require_venue_for_songs

  def venue
    venue = Venue.find_by(presence_token: params[:token])
    return redirect_to root_path, alert: 'That venue access code is not valid.' unless venue

    session[:venue_slug] = venue.slug
    redirect_to venue_songs_path(venue.slug)
  end

  def event
    presence = active_event_presence
    if presence.nil?
      return redirect_to root_path, alert: 'That event access code has expired or been revoked.'
    end

    remember_event_presence(presence)
    redirect_to_event_presence(presence.event)
  end

  def event_code
    return redirect_to root_path, alert: rate_limit_message unless event_code_allowed?

    presence = EventPresenceSession.active_at.find_by(short_code: normalized_event_code)
    if presence.nil?
      return redirect_to root_path, alert: 'That event access code has expired or is not valid.'
    end

    remember_event_presence(presence)
    redirect_to_event_presence(presence.event)
  end

  private

  def active_event_presence
    EventPresenceSession.active_at.find_by(token: params[:token])
  end

  def event_code_fingerprint
    Digest::SHA256.hexdigest([Rails.application.secret_key_base, request.remote_ip].join(':'))
  end

  def event_code_allowed?
    EventPresenceCodeLimiter.allow?(fingerprint: event_code_fingerprint)
  end

  def normalized_event_code
    params[:short_code].to_s.upcase.delete(' -')
  end

  def rate_limit_message
    'Too many access-code attempts. Try again in a minute.'
  end

  def redirect_to_event_presence(event)
    session[:venue_slug] = event.venue.slug
    redirect_to venue_event_queue_path(event.venue.slug, event_slug: event.slug)
  end
end
