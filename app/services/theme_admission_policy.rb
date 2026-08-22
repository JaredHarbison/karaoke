# frozen_string_literal: true

# Applies the active event theme to one candidate queue entry.
class ThemeAdmissionPolicy
  Result = Struct.new(:status, :reason, :application, keyword_init: true)

  def self.call(event:, metadata:, at: Time.current)
    new(event: event, metadata: metadata, at: at).call
  end

  def initialize(event:, metadata:, at:)
    @event = event
    @metadata = metadata
    @at = at
  end

  def call
    application = active_application
    return Result.new(status: :not_applicable, reason: 'no theme is active', application: nil) unless application

    decision = ThemeEligibilityPolicy.call(theme: application.theme, metadata: @metadata)
    Result.new(status: decision.status == :eligible ? :eligible : :review,
               reason: decision.reason, application: application)
  end

  private

  def active_application
    @event.event_theme_applications.includes(:theme).find { |application| application.active_at?(@at) }
  end
end
