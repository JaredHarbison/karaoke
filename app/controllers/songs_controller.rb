class SongsController < ApplicationController
  before_action :authenticate_user!
  protect_from_forgery with: :exception
  before_action :set_song, only: %i[ destroy edit finish_song show skip_song update ]
  before_action :authorize_song_owner, only: %i[ destroy edit update ]
  before_action :authorize_admin_for_queue_actions, only: %i[ finish_song skip_song ]

  # POST /:venue_slug/songs or /:venue_slug/songs.json
  def create
    @song = Song.new(song_params)
    @song.user = current_user
    @song.venue = Current.venue if Current.venue
    
    respond_to do |format|
      if @song.save
        format.html { redirect_to venue_songs_path(Current.venue.slug), notice: "A song was created for #{ @song.performer }." }
        format.turbo_stream
        format.json { render :show, status: :created, location: @song }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @song.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /:venue_slug/songs/1 or /:venue_slug/songs/1.json
  def destroy
    @performer = @song.performer
    @song.destroy
    respond_to do |format|
      format.html { redirect_to venue_songs_path(Current.venue.slug), notice: "#{@performer}'s song was removed." }
      format.turbo_stream
      format.json { head :no_content }
    end
  end

  # GET /:venue_slug/songs/1/edit
  def edit
  end

  # PATCH /:venue_slug/songs/1/finish_song
  def finish_song 
    if @song.update( finished: true ) 
      respond_to do |format|
        format.html { redirect_to venue_songs_path(Current.venue.slug), notice: "#{ @song.performer } just finished a song." }
        format.turbo_stream
      end
    else 
      respond_to do |format|
        format.html { redirect_to venue_songs_path(Current.venue.slug), alert: "#{ @song.performer }'s song was not finished." }
        format.turbo_stream
      end
    end
  end

  # GET /:venue_slug/songs
  def index
    @finished = Song.finished.order(updated_at: :desc)
    @skipped = Song.skipped
    @song = Song.new
    @songs = Song.all
    @upcoming = Song.upcoming
    @user_role = determine_user_role
  end
  
  # PATCH /:venue_slug/songs/1/skip_song
  def skip_song 
    skipped = !@song.skipped 
    if @song.update( skipped: skipped ) 
      respond_to do |format|
        format.html { redirect_to venue_songs_path(Current.venue.slug), notice: "#{ @song.performer } was #{ skipped ? 'skipped' : 'returned to' } the queue." }
        format.turbo_stream
      end
    else 
      respond_to do |format|
        format.html { redirect_to venue_songs_path(Current.venue.slug), alert: "#{ @song.performer }'s song could not be skipped." }
        format.turbo_stream
      end
    end
  end

  # PATCH/PUT /:venue_slug/songs/1 or /:venue_slug/songs/1.json
  def update
    respond_to do |format|
      if @song.update(song_params)
        format.html { redirect_to venue_songs_path(Current.venue.slug), notice: "#{@song.performer}'s song was successfully updated." }
        format.json { render :show, status: :ok, location: @song }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @song.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /:venue_slug/songs/1 
  def show
  end
  
  # GET /:venue_slug/songs/youtube_search
  def youtube_search
    query = params[:query]
    
    if query.blank?
      render json: { error: 'Query parameter is required' }, status: :bad_request
      return
    end
    
    results = YoutubeService.search(query)
    render json: results
  end
  
  # GET /:venue_slug/songs/validate_video
  def validate_video
    url = params[:url]
    
    if url.blank?
      render json: { valid: false, error: 'URL parameter is required' }, status: :bad_request
      return
    end
    
    validation = YoutubeService.validate_karaoke_video(url)
    render json: validation
  end

  private

  def set_song
    @song = Current.venue.songs.find(params[:id])
  end
    
  def song_params
    params.require(:song).permit(
      :category, 
      :finished, 
      :performer, 
      :postponed, 
      :url, 
      :skipped
    )
  end
  
  def authorize_song_owner
    unless @song.user == current_user || Current.venue.is_admin?(current_user)
      redirect_to venue_songs_path(Current.venue.slug), alert: "You can only edit or delete your own songs."
    end
  end
  
  def authorize_admin_for_queue_actions
    unless Current.venue.is_admin?(current_user)
      redirect_to venue_songs_path(Current.venue.slug), alert: "Only admins can manage the queue."
    end
  end
  
  def determine_user_role
    return :owner if Current.venue.owner_id == current_user.id
    return :admin if Current.venue.admins.include?(current_user)
    :performer
  end
end
