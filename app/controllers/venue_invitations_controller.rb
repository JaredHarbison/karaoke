class VenueInvitationsController < ApplicationController
  skip_before_action :require_venue_for_songs

  def show
    @invitation = VenueInvitation.pending.find_by(token: params[:token])

    unless @invitation
      redirect_to root_path, alert: 'That host invitation is invalid or has expired.'
      return
    end

    if user_signed_in?
      accept_invitation
    else
      session[:pending_venue_invitation_token] = @invitation.token
      redirect_to new_user_session_path(return_to: venue_invitation_path(@invitation.token)),
                  alert: "Sign in or create an account to host #{@invitation.venue.name}."
    end
  end

  private

  def accept_invitation
    @invitation.accept!(current_user)
    session.delete(:pending_venue_invitation_token)
    redirect_to venue_songs_path(@invitation.venue.slug), notice: "You can now help host #{@invitation.venue.name}."
  rescue ActiveRecord::RecordInvalid
    redirect_to root_path, alert: 'This invitation was sent to a different email address.'
  end
end
