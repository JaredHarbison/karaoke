class WelcomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @last_venue = Venue.find_by(slug: session[:venue_slug]) if session[:venue_slug].present?
    @venues = Venue.where(public: true)
    if params[:search].present?
      query = "%#{ActiveRecord::Base.sanitize_sql_like(params[:search])}%"
      @venues = @venues.where("name ILIKE ? OR slug ILIKE ? OR location ILIKE ?", query, query, query)
    end
    @venues = @venues.order(:name)
    @venue_events = venue_events_for(@venues)
    @queue_counts = Performance.unscoped.where(venue_id: @venues.select(:id), finished: false, skipped: false, postponed: false).group(:venue_id).count
  end

  private

  def venue_events_for(venues)
    venues.each_with_object({}) do |venue, events|
      events[venue.id] = current_event_for(venue)
    end
  end

  def current_event_for(venue)
    venue.events
         .where(status: %i[scheduled live])
         .order(Arel.sql("CASE WHEN status = #{Event.statuses.fetch('live')} THEN 0 ELSE 1 END"), :starts_at)
         .first
  end
end
