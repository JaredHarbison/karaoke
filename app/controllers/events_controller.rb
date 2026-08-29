# frozen_string_literal: true

# Lists and manages venue events.
class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_venue!
  before_action :require_admin!, only: %i[new create edit update]
  before_action :set_event, only: %i[show edit update start complete]
  before_action :require_event_host!, only: %i[start complete]

  def index
    @events = Current.venue.events.includes(:event_series).order(:starts_at)
  end

  def show
    load_show_data
  end

  def new
    @event = Current.venue.events.new(starts_at: 1.day.from_now.change(min: 0))
    load_event_form
  end

  def create
    @event = Current.venue.events.new

    if save_event_with_optional_recurrence
      redirect_to venue_event_path(Current.venue.slug, @event), notice: 'Event created.'
    else
      load_event_form
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    load_event_form
  end

  def update
    assign_event_attributes

    if @event.save
      @event.record_queue_overrun_change!(current_user)
      redirect_to venue_event_path(Current.venue.slug, @event), notice: 'Event updated.'
    else
      load_event_form
      render :edit, status: :unprocessable_entity
    end
  end

  def start
    if @event.start!
      @event.ensure_active_presence_session!(created_by_user: @event.venue.owner)
      redirect_to venue_event_path(Current.venue.slug, @event), notice: 'Event started. Performers may now queue songs.'
    else
      redirect_to venue_event_path(Current.venue.slug, @event), alert: 'Only scheduled events can be started.'
    end
  end

  def complete
    if @event.complete!
      redirect_to venue_event_path(Current.venue.slug, @event),
                  notice: 'Event completed. New queue submissions are closed.'
    else
      redirect_to venue_event_path(Current.venue.slug, @event), alert: 'Only live events can be completed.'
    end
  end

  private

  def load_show_data
    load_theme_data
    load_queue_audit_data
    load_delegation_data
  end

  def load_theme_data
    @themes = Current.venue.themes.where(active: true).order(:name)
    @theme_applications = @event.event_theme_applications.includes(:theme).order(:starts_at)
  end

  def load_queue_audit_data
    @queue_overrides = @event.song_queue_overrides.includes(:performance, :user).order(created_at: :desc).limit(10)
    @queue_setting_changes = @event.event_setting_changes.includes(:user).order(created_at: :desc).limit(10)
  end

  def load_delegation_data
    @event_host_delegations = @event.event_host_delegations
                                    .includes(:delegated_user, :delegated_by_user)
                                    .order(starts_at: :desc)
    @delegation_candidates = Current.venue.members.order(:email)
    ensure_live_event_access_code
    @presence_sessions = @event.event_presence_sessions.order(created_at: :desc)
    @active_presence_session = @presence_sessions.find { |presence| @event.live? && presence.active_at? }
  end

  def ensure_live_event_access_code
    return unless @event.live? && Current.venue.admin?(current_user)

    @event.ensure_active_presence_session!(created_by_user: current_user)
  end

  def set_event
    @event = Current.venue.events.find_by!(slug: params[:slug])
  end

  def load_event_form
    @event_series = Current.venue.event_series.where(active: true).order(:name)
    series = @event.event_series
    @recurrence = {
      enabled: params.dig(:recurrence, :enabled) == '1',
      frequency: params.dig(:recurrence, :frequency).presence || recurrence_frequency_for(series),
      interval: params.dig(:recurrence, :interval).presence || 1,
      unit: params.dig(:recurrence, :unit).presence || 'weeks',
      ends_at: params.dig(:recurrence, :ends_at).presence || series&.ends_at
    }
  end

  def save_event_with_optional_recurrence
    Event.transaction do
      assign_event_attributes
      assign_new_recurrence_if_requested
      @event.save!
    end
    true
  rescue ActiveRecord::RecordInvalid => e
    copy_recurrence_errors(e.record) if e.record.is_a?(EventSeries)
    false
  end

  def assign_new_recurrence_if_requested
    return unless recurrence_enabled?

    series = Current.venue.event_series.create!(
      name: @event.name,
      recurrence_rule: selected_recurrence_rule,
      starts_at: @event.starts_at,
      ends_at: recurrence_params[:ends_at],
      time_zone: Current.venue.time_zone,
      active: true
    )
    @event.event_series = series
  end

  def recurrence_enabled?
    recurrence_params[:enabled] == '1'
  end

  def recurrence_params
    params.fetch(:recurrence, {}).permit(:enabled, :frequency, :interval, :unit, :ends_at)
  end

  def selected_recurrence_rule
    return "FREQ=#{recurrence_frequency_for_unit};INTERVAL=#{recurrence_params[:interval]}" if recurrence_params[:frequency] == 'custom'

    recurrence_params[:frequency]
  end

  def recurrence_frequency_for(series)
    return 'FREQ=WEEKLY' unless series

    recurrence_frequency_options.include?(series.recurrence_rule) ? series.recurrence_rule : 'custom'
  end

  def recurrence_frequency_options
    %w[FREQ=DAILY FREQ=WEEKLY FREQ=MONTHLY FREQ=YEARLY]
  end

  def recurrence_frequency_for_unit
    { 'days' => 'DAILY', 'weeks' => 'WEEKLY', 'months' => 'MONTHLY', 'years' => 'YEARLY' }.fetch(recurrence_params[:unit], 'WEEKLY')
  end

  def copy_recurrence_errors(series)
    series.errors.full_messages.each { |message| @event.errors.add(:base, "Recurring event #{message.downcase}") }
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
    params.require(:event).permit(
      :name, :starts_at, :ends_at, :status, :event_series_id, :fair_queue_enabled, :allow_queue_overrun
    )
  end
end
