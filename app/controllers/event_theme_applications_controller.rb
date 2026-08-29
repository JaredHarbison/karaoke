# frozen_string_literal: true

# Applies reusable themes to events in the current venue.
class EventThemeApplicationsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_venue!
  before_action :require_admin!
  before_action :set_application, only: :destroy

  def create
    build_application
    redirect_after_create
  rescue ActiveRecord::RecordNotUnique
    redirect_to venue_event_queue_path(Current.venue.slug, event_slug: @event.slug),
                alert: 'Theme application could not be saved. Please try again.'
  end

  def destroy
    event = @application.event
    @application.destroy
    redirect_to venue_event_queue_path(Current.venue.slug, event_slug: event.slug), notice: 'Theme removed from event.'
  end

  private

  def set_application
    @application = Current.venue.event_theme_applications.find(params[:id])
  end

  def application_params
    params.require(:event_theme_application).permit(
      :event_id, :theme_name, :description, :match_examples_text, :required_keywords_text, :blocked_keywords_text,
      :starts_at, :ends_at
    )
  end

  def build_application
    attributes = application_params
    @event = Current.venue.events.find(attributes[:event_id])
    @theme = Current.venue.themes.find_or_initialize_by(name: attributes[:theme_name].to_s.strip)
    assign_new_theme_attributes(attributes) unless @theme.persisted?
    build_event_application(attributes)
  end

  def build_event_application(attributes)
    @application = @event.event_theme_applications.new(attributes.slice(:starts_at, :ends_at))
    @application.theme = @theme
  end

  def assign_new_theme_attributes(attributes)
    @theme.assign_attributes(
      description: attributes[:description],
      blocked_keywords_text: attributes[:blocked_keywords_text]
    )
    @theme.match_examples_text = attributes[:match_examples_text] if attributes[:match_examples_text].present?
    @theme.required_keywords_text = attributes[:required_keywords_text] if attributes[:required_keywords_text].present?
  end

  def save_theme_application
    @theme.save && @application.save
  end

  def redirect_after_create
    if save_theme_application
      redirect_to venue_event_queue_path(Current.venue.slug, event_slug: @event.slug), notice: 'Theme applied to event.'
    else
      redirect_to venue_event_queue_path(Current.venue.slug, event_slug: @event.slug), alert: application_errors
    end
  end

  def application_errors
    (@theme.errors.full_messages + @application.errors.full_messages).uniq.to_sentence
  end
end
