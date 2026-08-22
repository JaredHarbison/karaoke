class SongsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_queue_event
  before_action :require_admin!, only: %i[ presentation ]
  protect_from_forgery with: :exception
  before_action :set_song, only: %i[ destroy edit finish_song pause_song requeue_song show skip_song unpause_song update ]
  before_action :authorize_manageable_song!, only: %i[ destroy edit update ]
  before_action :authorize_admin_for_queue_actions, only: %i[ finish_song pause_song requeue_song skip_song unpause_song ]

  # POST /:venue_slug/songs or /:venue_slug/songs.json
  def create
    @song = Song.new(song_params)
    @song.user = current_user
    @song.venue = Current.venue if Current.venue
    @song.performer = current_user.display_name if @song.performer.blank?
    assign_song_event
    
    respond_to do |format|
      if save_song
        format.html { redirect_to queue_path, notice: "A song was created for #{ @song.performer }." }
        format.turbo_stream
        format.json { render :show, status: :created, location: @song }
      else
        format.html do
          load_queue
          render :index, status: :unprocessable_entity
        end
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
        format.json { head :no_content }
      end
    else 
      respond_to do |format|
        format.html { redirect_to venue_songs_path(Current.venue.slug), alert: "#{ @song.performer }'s song was not finished." }
        format.turbo_stream
        format.json { render json: @song.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /:venue_slug/songs
  def index
    @song = Song.new(event: @current_event)
    load_queue
  end

  # PATCH /:venue_slug/songs/1/pause_song
  def pause_song
    spots_back = Integer(params[:spots_back], exception: false)

    if spots_back.blank? || spots_back < 1
      redirect_to venue_songs_path(Current.venue.slug), alert: "Choose at least one spot to move the song back."
      return
    end

    SongQueue::Reorder.pause!(@song, spots_back, actor: current_user)
    redirect_to venue_songs_path(Current.venue.slug), notice: "#{@song.performer}'s song was paused."
  rescue ActiveRecord::RecordInvalid, ArgumentError
    redirect_to venue_songs_path(Current.venue.slug), alert: "#{@song.performer}'s song could not be paused."
  end

  # GET /:venue_slug/songs/presentation
  def presentation
    load_queue
    @presentation_time = Time.zone.now
    @presentation_next_song = @upcoming.first
    @presentation_event_name = Current.venue.name
    @presentation_theme = Current.venue.try(:theme).presence
  end

  # PATCH /:venue_slug/songs/1/requeue_song
  def requeue_song
    if @song.update(finished: false, skipped: false, postponed: false)
      redirect_to venue_songs_path(Current.venue.slug), notice: "#{@song.performer} was returned to the queue."
    else
      redirect_to venue_songs_path(Current.venue.slug), alert: "#{@song.performer}'s song could not be requeued."
    end
  end

  # PATCH /:venue_slug/songs/1/unpause_song
  def unpause_song
    SongQueue::Reorder.unpause!(@song, actor: current_user)
    redirect_to venue_songs_path(Current.venue.slug), notice: "#{@song.performer}'s song is next in line."
  rescue ActiveRecord::RecordInvalid, ArgumentError
    redirect_to venue_songs_path(Current.venue.slug), alert: "#{@song.performer}'s song could not be unpaused."
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
      assign_song_event
      if save_song
        format.html { redirect_to queue_path, notice: "#{@song.performer}'s song was successfully updated." }
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

  def load_queue
    @available_events = Current.venue.events.where(status: %i[scheduled live]).order(:starts_at)
    queue = @current_event ? Song.where(event: @current_event) : Song.all
    @finished = queue.finished.order(updated_at: :desc)
    @skipped = queue.skipped
    @songs = queue
    @upcoming = if @current_event&.fair_queue_enabled?
                  SongQueue::FairOrder.new(queue.upcoming, event: @current_event).call
                else
                  queue.upcoming.order(:updated_at)
                end
    @user_role = determine_user_role
    @can_manage_queue = Current.venue.is_admin?(current_user) || @current_event&.temporary_host?(current_user)
  end

  def set_queue_event
    return if params[:event_id].blank?

    @current_event = Current.venue.events.find_by(id: params[:event_id])
  end

  def assign_song_event
    attributes = song_params
    event_id = attributes.delete(:event_id)
    @song.assign_attributes(attributes)
    return if event_id.blank?

    @song.event = Event.find_by(id: event_id)
  end

  def queue_path
    event = @current_event || @song&.event
    venue_songs_path(Current.venue.slug, event_id: event&.id)
  end

  def set_song
    @song = Current.venue.songs.find(params[:id])
  end
    
  def song_params
    params.require(:song).permit(
      :category, 
      :event_id,
      :finished, 
      :performer, 
      :postponed, 
      :title,
      :url, 
      :skipped
    )
  end

  def save_song
    admission_error = event_queue_admission_error
    @song.errors.add(:base, admission_error) if admission_error
    admission_error.nil? && @song.save
  end

  def event_queue_admission_error
    event = @song.event
    return unless event
    unless event.live?
      return event.scheduled? ? 'This event has not started yet.' : 'This event is closed to new queue submissions.'
    end
    return 'Enter the event access code before queueing a song.' unless active_event_presence_for?(event)

    nil
  end
  
  def authorize_admin_for_queue_actions
    unless Current.venue.is_admin?(current_user) || @song.event&.temporary_host?(current_user)
      redirect_to venue_songs_path(Current.venue.slug), alert: "Only admins can manage the queue."
    end
  end

  def authorize_manageable_song!
    return if Current.venue.is_admin?(current_user)
    return if manageable_by_current_user?(@song)

    redirect_to venue_songs_path(Current.venue.slug), alert: "You can only manage songs you added or songs added for you."
  end
  
  def determine_user_role
    membership = Current.venue.membership_for(current_user)
    return membership.role.to_sym if membership&.owner? || membership&.admin?
    return :owner if Current.venue.owner?(current_user)
    return :host if @current_event&.temporary_host?(current_user)
    :performer
  end

  def manageable_by_current_user?(song)
    return false unless current_user.present?

    song.user == current_user || song.performer.to_s.casecmp(current_user.display_name.to_s).zero?
  end
end
