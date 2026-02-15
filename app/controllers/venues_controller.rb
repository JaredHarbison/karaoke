class VenuesController < ApplicationController
  before_action :authenticate_user!, except: [:discover, :join]
  before_action :set_venue, only: [:settings, :update_settings]
  before_action :require_owner!, only: [:settings, :update_settings, :create_admin, :destroy_admin]
  
  # GET /discover - Browse and search venues
  def discover
    @venues = if params[:search].present?
      Venue.where("name ILIKE ? OR slug ILIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
            .where(public: true)
            .order(:name)
    else
      Venue.where(public: true).order(:name)
    end
  end
  
  # POST /venues/join/:slug - Join a venue
  def join
    @venue = Venue.find_by(slug: params[:slug])
    
    unless @venue&.public?
      redirect_to discover_venues_path, alert: 'Venue not found or is not accepting new users.'
      return
    end
    
    session[:venue_slug] = @venue.slug
    redirect_to venue_songs_path(@venue.slug), notice: "Welcome to #{@venue.name}!"
  end
  
  # GET /:venue_slug/settings - Venue settings (owner only)
  def settings
    @admins = @venue.admins
    @admin_search_results = []
  end
  
  # PATCH /:venue_slug/settings - Update settings (owner only)
  def update_settings
    if @venue.update(venue_params)
      redirect_to venue_settings_path(@venue.slug), notice: 'Venue settings updated successfully.'
    else
      render :settings, alert: 'Failed to update venue settings.'
    end
  end
  
  # GET /:venue_slug/admins - List admins (owner only)
  def admins_list
    @admins = @venue.admins
  end
  
  # POST /:venue_slug/admins - Add admin (owner only)
  def create_admin
    @user = User.find_by(email: params[:email])
    
    unless @user
      head :not_found
      return
    end
    
    @venue.add_admin(@user)
    
    respond_to do |format|
      format.html { redirect_to venue_settings_path(@venue.slug), notice: "#{@user.email} added as admin." }
      format.turbo_stream
    end
  end
  
  # DELETE /:venue_slug/admins/:id - Remove admin (owner only)
  def destroy_admin
    @user = User.find(params[:id])
    @venue.remove_admin(@user)
    
    respond_to do |format|
      format.html { redirect_to venue_settings_path(@venue.slug), notice: "#{@user.email} removed as admin." }
      format.turbo_stream
    end
  end
  
  private
  
  def set_venue
    @venue = Venue.find_by(slug: params[:venue_slug])
    redirect_to discover_venues_path, alert: 'Venue not found.' unless @venue
  end
  
  def venue_params
    params.require(:venue).permit(:name, :public)
  end
end
