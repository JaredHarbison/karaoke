# frozen_string_literal: true

# Creates and revokes expiring event presence sessions.
class EventPresenceSessionsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_venue!
  before_action :require_admin!
  before_action :set_event
  before_action :set_presence_session, only: :destroy

  def create
    rotate_presence_session
    redirect_to venue_event_path(Current.venue.slug, @event), notice: 'Event access code generated.'
  rescue ActiveRecord::RecordInvalid => e
    redirect_to venue_event_path(Current.venue.slug, @event), alert: e.record.errors.full_messages.to_sentence
  end

  def destroy
    @presence_session.update!(revoked_at: Time.current)
    redirect_to venue_event_path(Current.venue.slug, @event), notice: 'Event access code revoked.'
  end

  private

  def set_event
    @event = Current.venue.events.find(params[:event_id])
  end

  def set_presence_session
    @presence_session = @event.event_presence_sessions.find(params[:id])
  end

  def rotate_presence_session
    EventPresenceSession.rotate_for!(
      event: @event,
      created_by_user: current_user,
      expires_at: session_expiry
    )
  end

  def session_expiry
    requested = Time.zone.parse(params[:expires_at].to_s) if params[:expires_at].present?
    event_end = (@event.ends_at || @event.starts_at + 4.hours) + EventPresenceSession::GRACE_PERIOD
    [requested || event_end, event_end].min
  end
end
