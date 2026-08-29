# frozen_string_literal: true

# Creates and revokes time-limited host authority for venue events.
class EventHostDelegationsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_venue!
  before_action :require_admin!
  before_action :set_event
  before_action :set_delegation, only: :destroy

  def create
    @delegation = new_delegation

    if @delegation.save
      redirect_to venue_event_queue_path(Current.venue.slug, event_slug: @event.slug),
                  notice: 'Temporary host delegation created.'
    else
      redirect_to venue_event_queue_path(Current.venue.slug, event_slug: @event.slug),
                  alert: @delegation.errors.full_messages.to_sentence
    end
  end

  def destroy
    @delegation.update!(revoked_at: Time.current)
    redirect_to venue_event_queue_path(Current.venue.slug, event_slug: @event.slug),
                notice: 'Temporary host delegation revoked.'
  end

  private

  def set_event
    @event = Current.venue.events.find(params[:event_id])
  end

  def set_delegation
    @delegation = @event.event_host_delegations.find(params[:id])
  end

  def delegation_params
    attributes = params.require(:event_host_delegation).permit(:delegated_user_id, :starts_at, :ends_at)
    attributes[:delegated_user_id] = delegation_candidates.find_by(id: attributes[:delegated_user_id])&.id
    attributes
  end

  def delegation_candidates
    @event.temporary_host_candidates
  end

  def new_delegation
    @event.event_host_delegations.new(delegation_params.merge(delegated_by_user: current_user))
  end
end
