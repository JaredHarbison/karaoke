# frozen_string_literal: true

# Applies reusable themes to events in the current venue.
class EventThemeApplicationsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_venue!
  before_action :require_admin!
  before_action :set_application, only: :destroy

  def create
    build_application

    if @application.save
      redirect_to venue_event_path(Current.venue.slug, @event), notice: 'Theme applied to event.'
    else
      redirect_to venue_event_path(Current.venue.slug, @event), alert: @application.errors.full_messages.to_sentence
    end
  end

  def destroy
    event = @application.event
    @application.destroy
    redirect_to venue_event_path(Current.venue.slug, event), notice: 'Theme removed from event.'
  end

  private

  def set_application
    @application = Current.venue.event_theme_applications.find(params[:id])
  end

  def application_params
    params.require(:event_theme_application).permit(:event_id, :theme_id, :starts_at, :ends_at)
  end

  def build_application
    attributes = application_params
    @event = Current.venue.events.find(attributes[:event_id])
    @application = @event.event_theme_applications.new(attributes.except(:event_id, :theme_id))
    @application.theme = Current.venue.themes.find(attributes[:theme_id])
  end
end
