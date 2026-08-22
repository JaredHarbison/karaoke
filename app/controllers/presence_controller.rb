# frozen_string_literal: true

# Resolves permanent venue and expiring event presence bearer URLs.
class PresenceController < ApplicationController
  skip_before_action :require_venue_for_songs

  def venue
    venue = Venue.find_by(presence_token: params[:token])
    return redirect_to discover_venues_path, alert: 'That venue access code is not valid.' unless venue

    session[:venue_slug] = venue.slug
    redirect_to venue_songs_path(venue.slug)
  end

  def event
    presence = active_event_presence
    if presence.nil?
      return redirect_to discover_venues_path, alert: 'That event access code has expired or been revoked.'
    end

    remember_event_presence(presence)
    redirect_to_event_presence(presence.event)
  end

  def event_code
    normalized_code = params[:short_code].to_s.upcase.delete(' -')
    presence = EventPresenceSession.active_at.find_by(short_code: normalized_code)
    if presence.nil?
      return redirect_to discover_venues_path, alert: 'That event access code has expired or is not valid.'
    end

    remember_event_presence(presence)
    redirect_to_event_presence(presence.event)
  end

  private

  def active_event_presence
    EventPresenceSession.active_at.find_by(token: params[:token])
  end

  def redirect_to_event_presence(event)
    session[:venue_slug] = event.venue.slug
    redirect_to venue_songs_path(event.venue.slug, event_id: event.id)
  end
end
