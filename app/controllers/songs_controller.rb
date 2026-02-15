class SongsController < ApplicationController
  before_action :authenticate_user!
  protect_from_forgery with: :exception
  before_action :set_song, only: %i[ destroy edit finish_song show skip_song update ]
  before_action :authorize_song_owner, only: %i[ destroy edit update ]

  # POST /songs or /songs.json
  def create
    @song = Song.new(song_params)
    @song.user = current_user
    @song.venue = Current.venue if Current.venue
    
    respond_to do |format|
      if @song.save
        format.html { redirect_to songs_url, notice: "A song was created for #{ @song.performer }." }
        format.json { render :show, status: :created, location: @song }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @song.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /songs/1 or /songs/1.json
  def destroy
    @song.destroy
    respond_to do |format|
      format.html { redirect_to songs_url, notice: "#{@performer}'s song was removed." }
      format.json { head :no_content }
    end
  end

  # GET /songs/1/edit
  def edit
  end

  # method to click a button and finish a song
  def finish_song 
    if @song.update( finished: true ) 
      redirect_to songs_url, notice: "#{ @song.performer } just finished a song." 
    else 
      redirect_to songs_url, error: "#{ @song.performer }'s song was not finished."
    end
  end

  # GET /songs
  def index
    @finished = Song.finished
    @postponed = Song.postponed
    @skipped = Song.skipped
    @song = Song.new
    @songs = Song.all
    @upcoming = Song.upcoming
  end
  
  # method to click a button and skip a song
  def skip_song 
    skipped = !@song.skipped 
    if @song.update( skipped: skipped ) 
      redirect_to songs_url, notice: "#{ @song.performer } just skipped a song." 
    else 
      redirect_to songs_url, error: "#{ @song.performer }'s song was not skipped."
    end
  end

  # PATCH/PUT /songs/1 or /songs/1.json
  def update
    respond_to do |format|
      if @song.update(song_params)
        format.html { redirect_to songs_url, notice: "#{@performer}'s song was successfully updated." }
        format.json { render :show, status: :ok, location: @song }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @song.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /songs/1 
  def show
  end
  
  # GET /songs/youtube_search
  def youtube_search
    query = params[:query]
    
    if query.blank?
      render json: { error: 'Query parameter is required' }, status: :bad_request
      return
    end
    
    results = YoutubeService.search(query)
    render json: results
  end
  
  # GET /songs/validate_video
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
    @song = Song.find( params[ :id ] )
  end
    
  def song_params
    params.require( :song ).permit(
      :category, 
      :finished, 
      :performer, 
      :postponed, 
      :url, 
      :skipped
    )
  end
  
  def authorize_song_owner
    unless @song.user == current_user
      redirect_to songs_url, alert: "You can only edit or delete your own songs."
    end
  end

end
