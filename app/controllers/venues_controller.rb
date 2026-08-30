class VenuesController < ApplicationController
  before_action :authenticate_user!, except: [:join]
  before_action :set_venue, only: [:settings, :update_settings, :create_admin, :destroy_admin]
  before_action :require_owner!, only: [:settings, :update_settings, :create_admin, :destroy_admin]
  
  # POST /venues/join/:slug - Join a venue
  def join
    @venue = Venue.find_by(slug: params[:slug])
    
    unless @venue&.public?
      redirect_to root_path, alert: 'Venue not found or is not accepting new users.'
      return
    end

    session[:venue_slug] = @venue.slug
    event = @venue.events.current_or_upcoming.order(:starts_at).first
    destination = event_entry_path(@venue, event)
    redirect_to destination, notice: "Welcome to #{@venue.name}!"
  end
  
  # GET /:venue_slug/settings - Venue settings (owner only)
  def settings
    @hosts = @venue.hosts
    @admin_search_results = []
    @time_zones = ActiveSupport::TimeZone.all.sort_by(&:name)
  end
  
  # PATCH /:venue_slug/settings - Update settings (owner only)
  def update_settings
    if @venue.update(venue_params)
      redirect_to venue_settings_path(@venue.slug), notice: 'Venue settings updated successfully.'
    else
      @hosts = @venue.hosts
      @admin_search_results = []
      @time_zones = ActiveSupport::TimeZone.all.sort_by(&:name)
      render :settings, alert: 'Failed to update venue settings.'
    end
  end
  
  # GET /:venue_slug/admins - List admins (owner only)
  def admins_list
    @hosts = @venue.hosts
  end
  
  # POST /:venue_slug/admins - Add admin (owner only)
  def create_admin
    @user = User.find_by(email: params[:email])
    
    unless @user
      invitation = @venue.invitations.create!(invited_by: current_user, email: params[:email])
      respond_to do |format|
        message = "Invite created: #{venue_invitation_url(invitation.token)}"
        format.html { redirect_to venue_settings_path(@venue.slug), notice: message }
        format.turbo_stream { redirect_to venue_settings_path(@venue.slug), status: :see_other, notice: message }
      end
      return
    end

    if @user == @venue.owner
      respond_to do |format|
        format.html { redirect_to venue_settings_path(@venue.slug), alert: 'The venue owner already has full queue access.' }
        format.turbo_stream { redirect_to venue_settings_path(@venue.slug), status: :see_other, alert: 'The venue owner already has full queue access.' }
      end
      return
    end
    
    @venue.add_host(@user)
    message = "#{@user.email} added as host."
    
    respond_to do |format|
      format.html { redirect_to venue_settings_path(@venue.slug), notice: message }
      format.turbo_stream { redirect_to venue_settings_path(@venue.slug), status: :see_other, notice: message }
    end
  end
  
  # DELETE /:venue_slug/admins/:id - Remove admin (owner only)
  def destroy_admin
    @user = User.find(params[:id])
    @venue.remove_host(@user)
    message = "#{@user.email} removed as host."
    
    respond_to do |format|
      format.html { redirect_to venue_settings_path(@venue.slug), notice: message }
      format.turbo_stream { redirect_to venue_settings_path(@venue.slug), status: :see_other, notice: message }
    end
  end
  
  private
  
  def set_venue
    @venue = Venue.find_by(slug: params[:venue_slug])
    redirect_to root_path, alert: 'Venue not found.' unless @venue
  end
  
  def venue_params
    params.require(:venue).permit(:name, :location, :public, :explicit_lyrics_allowed, :time_zone)
  end
end
