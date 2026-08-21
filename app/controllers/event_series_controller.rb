# frozen_string_literal: true

# Manages recurring event-series intent for a venue.
class EventSeriesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_venue!
  before_action :require_admin!
  before_action :set_event_series, only: %i[edit update]

  def index
    @event_series = Current.venue.event_series.order(:name)
  end

  def new
    @event_series = Current.venue.event_series.new(
      starts_at: 1.day.from_now.change(min: 0),
      time_zone: Time.zone.name
    )
  end

  def create
    @event_series = Current.venue.event_series.new(event_series_params)

    if @event_series.save
      redirect_to venue_event_series_index_path(Current.venue.slug), notice: 'Recurring series created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @event_series.update(event_series_params)
      redirect_to venue_event_series_index_path(Current.venue.slug), notice: 'Recurring series updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_event_series
    @event_series = Current.venue.event_series.find(params[:id])
  end

  def event_series_params
    params.require(:event_series).permit(:name, :recurrence_rule, :starts_at, :ends_at, :time_zone, :active)
  end
end
