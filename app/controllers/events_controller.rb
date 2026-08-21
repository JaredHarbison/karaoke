# frozen_string_literal: true

# Lists and manages venue events.
class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_venue!
  before_action :require_admin!, only: %i[new create edit update]
  before_action :set_event, only: %i[show edit update]

  def index
    @events = Current.venue.events.includes(:event_series).order(:starts_at)
  end

  def show
    @themes = Current.venue.themes.where(active: true).order(:name)
    @theme_applications = @event.event_theme_applications.includes(:theme).order(:starts_at)
  end

  def new
    @event = Current.venue.events.new(starts_at: 1.day.from_now.change(min: 0))
    load_event_series
  end

  def create
    @event = Current.venue.events.new
    assign_event_attributes

    if @event.save
      redirect_to venue_event_path(Current.venue.slug, @event), notice: 'Event created.'
    else
      load_event_series
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    load_event_series
  end

  def update
    assign_event_attributes

    if @event.save
      redirect_to venue_event_path(Current.venue.slug, @event), notice: 'Event updated.'
    else
      load_event_series
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_event
    @event = Current.venue.events.find(params[:id])
  end

  def load_event_series
    @event_series = Current.venue.event_series.where(active: true).order(:name)
  end

  def assign_event_attributes
    attributes = event_params
    series_id = attributes.delete(:event_series_id)
    @event.assign_attributes(attributes)
    return if series_id.blank?

    @event.event_series = Current.venue.event_series.find_by(id: series_id)
    @event.errors.add(:event_series, 'is not available for this venue') unless @event.event_series
  end

  def event_params
    params.require(:event).permit(:name, :starts_at, :ends_at, :status, :event_series_id)
  end
end
