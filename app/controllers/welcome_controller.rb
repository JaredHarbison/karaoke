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
    @queue_counts = Performance.unscoped.where(venue_id: @venues.select(:id), finished: false, skipped: false, postponed: false).group(:venue_id).count
  end
end
