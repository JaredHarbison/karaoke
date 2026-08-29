require 'rails_helper'

RSpec.describe 'Songs', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:venue) { create(:venue) }
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe 'GET /venues/:venue_slug/songs' do
    it 'displays songs for the venue', :critical do
      create(:performance, venue: venue, user: user)
      get "/#{venue.slug}/songs"
      expect(response).to be_successful
    end

    it 'provides shared queue, add-song, and QR tabs for owners' do
      sign_out user
      sign_in venue.owner

      get "/#{venue.slug}/songs"

      page = Nokogiri::HTML(response.body)
      expect(response.body).to include('songs-page--manager')
      expect(page.css('[role="tab"]').map(&:text).map(&:strip)).to eq(['Queue', 'Add Song'])
      expect(page.css('[role="tabpanel"]').map { |panel| panel['id'] }).to eq(['queue-panel', 'add-panel'])
      expect(page.css('.songs-tab-panels > [role="tabpanel"]').length).to eq(2)
      expect(response.body).to include('songs-help-dialog')
      expect(response.body).to include('songs-panel--finished')
      expect(response.body).to include('app-shell__header', 'app-menu__summary')
      expect(response.body).not_to include('Fair Queue favors performers')
      expect(page.at_css('.songs-page')['data-controller']).to eq('youtube-player')
      expect(response.body).to include('song-player__viewport')
    end

    it 'prioritizes add-song controls before the queue for performers' do
      get "/#{venue.slug}/songs"

      expect(response.body.index('songs-panel--add')).to be < response.body.index('songs-panel--queue')
    end

    it 'renders fields for the YouTube selector to populate' do
      get "/#{venue.slug}/songs"

      page = Nokogiri::HTML(response.body)
      expect(page.at_css('input#song_url')['name']).to eq('song[url]')
      expect(page.at_css('input#song_title')['name']).to eq('song[title]')
      expect(page.at_css('form[data-controller="youtube-search"]')['data-action']).to include('submit->youtube-search#submit')
    end

    it 'opens the event access-code step for an event queue' do
      event = create(
        :event, venue: venue, status: :live, starts_at: 1.hour.ago, ends_at: 2.hours.from_now
      )

      get venue_event_queue_path(venue.slug, event_slug: event.slug)

      dialog = Nokogiri::HTML(response.body).at_css('dialog.songs-access-dialog')
      expect(dialog).to have_attribute('open')
    end

    it 'shows active event themes above the add-song controls' do
      event = create(
        :event, venue: venue, status: :live, starts_at: 1.hour.ago, ends_at: 2.hours.from_now
      )
      theme = create(:theme, venue: venue, name: 'Disco Hour')
      create(:event_theme_application, event: event, theme: theme)

      sign_out user
      sign_in venue.owner
      get venue_event_queue_path(venue.slug, event_slug: event.slug)

      page = Nokogiri::HTML(response.body)
      theme_notice = page.at_css('.songs-active-theme')
      expect(theme_notice.text).to include('Disco Hour')
      expect(theme_notice.at_css('span').text).to include('–')
      expect(response.body.index('songs-active-themes')).to be < response.body.index('youtube-search')
    end

    it 'shows Play only for the next queued song' do
      sign_out user
      sign_in venue.owner
      create_list(:performance, 2, venue: venue)

      get "/#{venue.slug}/songs"

      expect(Nokogiri::HTML(response.body).css('.song-action--play').count).to eq(1)
    end

    it 'uses concise possessive copy in the pause dialog' do
      sign_out user
      sign_in venue.owner
      create(:performance, venue: venue, performer: 'Jared Harbison', title: 'Black Velvet')

      get "/#{venue.slug}/songs"

      expect(response.body).to include("Pause Jared Harbison's song")
      expect(response.body).to include('Move back by')
      expect(response.body).not_to include('>spots<')
    end

    it 'offers a direct video link for queue managers' do
      sign_out user
      sign_in venue.owner
      create(:performance, venue: venue)

      get "/#{venue.slug}/songs"

      page = Nokogiri::HTML(response.body)
      expect(page.css('.song-action--open').count).to eq(1)
      expect(page.at_css('.song-action--open')['target']).to eq('_blank')
    end

    it 'shows the song title to queue managers' do
      sign_out user
      sign_in venue.owner
      create(:performance, venue: venue, title: 'Black Velvet')

      get "/#{venue.slug}/songs"

      page = Nokogiri::HTML(response.body)
      expect(page.css('.song-queue-card__meta').text).to include('Black Velvet')
    end

    it 'uses a simple performer and song hierarchy without category pills' do
      sign_out user
      sign_in venue.owner
      create(:performance, venue: venue, user: nil, performer: 'Jared Harbison', title: 'Black Velvet', category: 'QA')

      get "/#{venue.slug}/songs"

      page = Nokogiri::HTML(response.body)
      card = page.css('.song-queue-card').last
      expect(card.at_css('.song-queue-card__title-row h3').text).to include('Jared H.')
      expect(card.at_css('.song-queue-card__meta').text).to include('Black Velvet')
      expect(card.at_css('.song-category')).to be_nil
    end

    it 'reveals larger queues in pages of ten' do
      sign_out user
      sign_in venue.owner
      11.times { |index| create(:performance, venue: venue, user: nil, performer: "Singer #{index}", title: "Song #{index}") }

      get "/#{venue.slug}/songs"

      page = Nokogiri::HTML(response.body)
      expect(page.css('.song-queue-card').length).to eq(10)
      expect(page.at_css('.songs-more-button').text).to include('More')

      get "/#{venue.slug}/songs", params: { page: 2 }

      expect(Nokogiri::HTML(response.body).css('.song-queue-card').length).to eq(11)
    end

    it 'shows a normalized song name instead of a provider URL or karaoke descriptors' do
      sign_out user
      sign_in venue.owner
      create(:performance, venue: venue, performer: 'Jared Harbison', title: 'Faithfully - Journey (Full Band Karaoke) Female Key - Instrumental')

      get "/#{venue.slug}/songs"

      card = Nokogiri::HTML(response.body).css('.song-queue-card').last
      title = card.at_css('.song-queue-card__meta').text.strip
      expect(title).to eq('Faithfully - Journey')
      expect(title).not_to include('youtube.com', 'Karaoke', 'Instrumental')
    end

    it 'shows archive management actions to owners' do
      sign_out user
      sign_in venue.owner
      create(:performance, :finished, venue: venue)

      get "/#{venue.slug}/songs"

      page = Nokogiri::HTML(response.body)
      expect(page.css('.song-action--requeue').count).to eq(1)
      expect(page.css('.songs-panel--finished .song-action--remove').count).to eq(1)
    end

    it 'does not show archive management actions to performers' do
      create(:performance, :finished, venue: venue)

      get "/#{venue.slug}/songs"

      page = Nokogiri::HTML(response.body)
      expect(page.css('.songs-panel--finished .song-queue-card__actions').text.strip).to be_empty
    end

    it 'requires authentication' do
      sign_out user
      get "/#{venue.slug}/songs"
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe 'POST /venues/:venue_slug/songs' do
    it 'creates a new song', :critical do
      expect {
        post "/#{venue.slug}/songs", params: { song: { performer: 'Test Artist', url: 'https://youtube.com/test', category: 'pop' } }
      }.to change(Performance, :count).by(1)
      expect(response).to redirect_to("/#{venue.slug}/songs")
    end

    it 'uses the signed-in user name when a selected video omits performer' do
      expect {
        post "/#{venue.slug}/songs", params: { song: { url: 'https://youtube.com/watch?v=test' } }
      }.to change(Performance, :count).by(1)

      expect(Performance.last.performer).to eq(user.display_name)
      expect(response).to redirect_to("/#{venue.slug}/songs")
    end

    it 'associates a song with an event in the current venue' do
      event = create(:event, venue: venue, status: :live)
      presence = create(:event_presence_session, event: event, created_by_user: venue.owner, expires_at: event.ends_at)
      get event_presence_path(presence.token)
      allow(YoutubeService).to receive(:validate_karaoke_video).and_return(
        { video_id: 'event-video', verified_karaoke: true, explicit_lyrics: false, duration_seconds: 180 }
      )

      post venue_event_queue_path(venue.slug, event_slug: event.slug), params: {
        song: { performer: 'Event Singer', url: 'https://youtube.com/event' }
      }

      expect(response).to redirect_to(venue_event_queue_path(venue.slug, event_slug: event.slug))
      expect(Performance.last.event).to eq(event)
      expect(Performance.last).to have_attributes(metadata_status: 'eligible', duration_seconds: 180, duration_source: 'provider')
    end

    it 'does not create a duplicate when the same submission is retried' do
      event = create(:event, venue: venue, status: :live)
      presence = create(:event_presence_session, event: event, created_by_user: venue.owner, expires_at: event.ends_at)
      get event_presence_path(presence.token)
      allow(YoutubeService).to receive(:validate_karaoke_video).and_return(
        { video_id: 'retry-video', verified_karaoke: true, explicit_lyrics: false, duration_seconds: 180 }
      )
      params = { song: { performer: 'Retry Singer', url: 'https://youtube.com/retry', submission_token: SecureRandom.uuid } }

      expect { post venue_event_queue_path(venue.slug, event_slug: event.slug), params: params }.to change(Performance, :count).by(1)
      expect { post venue_event_queue_path(venue.slug, event_slug: event.slug), params: params }.not_to change(Performance, :count)
      expect(response).to redirect_to(venue_event_queue_path(venue.slug, event_slug: event.slug))
      expect(flash[:notice]).to include('already queued')
    end

    it 'holds a theme-ineligible song for host review and allows approval' do
      event = create(:event, venue: venue, status: :live, starts_at: 1.hour.ago)
      theme = create(:theme, venue: venue, rules: { 'required_keywords' => ['disco'] })
      create(:event_theme_application, event: event, theme: theme)
      presence = create(:event_presence_session, event: event, created_by_user: venue.owner, expires_at: event.ends_at)
      get event_presence_path(presence.token)
      allow(YoutubeService).to receive(:validate_karaoke_video).and_return(
        { video_id: 'theme-video', verified_karaoke: true, explicit_lyrics: false, duration_seconds: 180, title: 'Unknown Song' }
      )

      expect do
        post venue_event_queue_path(venue.slug, event_slug: event.slug), params: { song: { performer: 'Theme Singer', url: 'https://youtube.com/theme' } }
      end.to change(Performance, :count).by(1)
      song = Performance.last
      expect(song.theme_admission_status).to eq('review')
      expect(flash[:notice]).to include('needs theme review')

      sign_out user
      sign_in venue.owner
      patch review_theme_venue_song_path(venue.slug, song), params: { decision: 'approve' }

      expect(song.reload).to have_attributes(theme_admission_status: 'eligible', theme_reviewed_by: venue.owner)
    end

    it 'lets a host schedule a theme-mismatched song after the theme window' do
      event = create(:event, venue: venue, status: :live, starts_at: 1.hour.ago, ends_at: 2.hours.from_now)
      theme = create(:theme, venue: venue)
      application = create(
        :event_theme_application, event: event, theme: theme, starts_at: 30.minutes.ago, ends_at: 30.minutes.from_now
      )
      song = create(
        :performance,
        venue: venue,
        event: event,
        theme_application: application,
        theme_admission_status: 'review',
        theme_admission_reason: 'metadata does not satisfy required theme keywords'
      )
      sign_out user
      sign_in venue.owner

      patch review_theme_venue_song_path(venue.slug, song), params: { decision: 'defer' }

      expect(song.reload).to have_attributes(theme_admission_status: 'deferred', theme_reviewed_by: venue.owner)
      ThemeAdmissionRelease.call(event: event, at: application.ends_at + 1.second)
      expect(song.reload.theme_admission_status).to eq('released')
    end

    it 'holds explicit lyrics for reject-only content-policy review during a theme' do
      event = create(:event, venue: venue, status: :live, starts_at: 1.hour.ago)
      theme = create(:theme, venue: venue)
      create(:event_theme_application, event: event, theme: theme)
      presence = create(:event_presence_session, event: event, created_by_user: venue.owner, expires_at: event.ends_at)
      get event_presence_path(presence.token)
      allow(YoutubeService).to receive(:validate_karaoke_video).and_return(
        { video_id: 'explicit-theme-video', verified_karaoke: true, explicit_lyrics: true, duration_seconds: 180, title: 'Explicit Song' }
      )

      expect do
        post venue_event_queue_path(venue.slug, event_slug: event.slug), params: { song: { performer: 'Policy Singer', url: 'https://youtube.com/explicit-theme' } }
      end.to change(Performance, :count).by(1)
      song = Performance.last
      expect(song).to have_attributes(theme_admission_status: 'review')

      sign_out user
      sign_in venue.owner
      patch review_theme_venue_song_path(venue.slug, song), params: { decision: 'reject', rejection_reason: 'content_policy' }

      expect(song.reload).to have_attributes(
        theme_admission_status: 'rejected',
        theme_admission_reason: 'host rejected content policy admission',
        theme_reviewed_by: venue.owner
      )
    end

    it 'rejects event queueing before the host starts the event' do
      event = create(:event, venue: venue)

      expect do
        post venue_event_queue_path(venue.slug, event_slug: event.slug), params: { song: { performer: 'Early Singer', url: 'https://youtube.com/early' } }
      end.not_to change(Performance, :count)

      expect(response).to have_http_status(422)
      expect(response.body).to include('This event has not started yet.')
    end

    it 'rejects live event queueing without an active event presence session' do
      event = create(:event, venue: venue, status: :live)

      expect do
        post venue_event_queue_path(venue.slug, event_slug: event.slug), params: { song: { performer: 'Remote Singer', url: 'https://youtube.com/remote' } }
      end.not_to change(Performance, :count)

      expect(response).to have_http_status(422)
      expect(response.body).to include('Enter the event access code before queueing a song.')
      expect(response.body).to include('Enter the six-character code shown on the venue display to join this event queue.')
      expect(Nokogiri::HTML(response.body).at_css('input[name="short_code"]').has_attribute?('autofocus')).to be(true)
    end

    it 'keeps an event queue validation error on the canonical event queue path' do
      event = create(:event, venue: venue, status: :live)

      post venue_event_queue_path(venue.slug, event_slug: event.slug), params: {
        song: { performer: 'Remote Singer', url: 'https://youtube.com/remote' }
      }

      expect(response).to have_http_status(422)
      expect(request.path).to eq(venue_event_queue_path(venue.slug, event_slug: event.slug))
      expect(response.body).to include('Enter the event access code before queueing a song.')
    end

    it 'allows a venue owner to queue for a live event without an access code' do
      event = create(:event, venue: venue, status: :live)
      sign_out user
      sign_in venue.owner
      allow(YoutubeService).to receive(:validate_karaoke_video).and_return(
        { video_id: 'owner-video', verified_karaoke: true, explicit_lyrics: false, duration_seconds: 180 }
      )

      expect do
        post venue_event_queue_path(venue.slug, event_slug: event.slug), params: { song: { performer: 'Host Singer', url: 'https://youtube.com/owner' } }
      end.to change(Performance, :count).by(1)

      expect(response).to redirect_to(venue_event_queue_path(venue.slug, event_slug: event.slug))
    end

    it 'rejects queueing after an event is completed even during presence grace' do
      event = create(:event, venue: venue, status: :completed)
      presence = create(:event_presence_session, event: event, created_by_user: venue.owner, expires_at: event.ends_at)
      get event_presence_path(presence.token)

      expect do
        post venue_event_queue_path(venue.slug, event_slug: event.slug), params: { song: { performer: 'Late Singer', url: 'https://youtube.com/late' } }
      end.not_to change(Performance, :count)

      expect(response).to have_http_status(422)
      expect(
        ['This event has not started yet.', 'This event is closed'].any? { |message| response.body.include?(message) }
      ).to be(true)
    end

    it 'rejects an admitted song when it would extend the queue beyond event end' do
      event = create(:event, venue: venue, status: :live, starts_at: 1.hour.ago, ends_at: 2.minutes.from_now)
      presence = create(:event_presence_session, event: event, created_by_user: venue.owner, expires_at: event.ends_at)
      get event_presence_path(presence.token)
      allow(YoutubeService).to receive(:validate_karaoke_video).and_return(
        { video_id: 'long-video', verified_karaoke: true, explicit_lyrics: false, duration_seconds: 180 }
      )

      expect do
        post venue_event_queue_path(venue.slug, event_slug: event.slug), params: { song: { performer: 'Overrun Singer', url: 'https://youtube.com/long' } }
      end.not_to change(Performance, :count)

      expect(response).to have_http_status(422)
      expect(response.body).to include('beyond the event end')
    end

    it 'allows a song beyond event end when the host override is enabled' do
      event = create(:event, venue: venue, status: :live, starts_at: 1.hour.ago, ends_at: 2.minutes.from_now, allow_queue_overrun: true)
      presence = create(:event_presence_session, event: event, created_by_user: venue.owner, expires_at: event.ends_at)
      get event_presence_path(presence.token)
      allow(YoutubeService).to receive(:validate_karaoke_video).and_return(
        { video_id: 'override-video', verified_karaoke: true, explicit_lyrics: false, duration_seconds: 180 }
      )

      expect do
        post venue_event_queue_path(venue.slug, event_slug: event.slug), params: { song: { performer: 'Override Singer', url: 'https://youtube.com/override' } }
      end.to change(Performance, :count).by(1)
    end
  end

  describe 'event-scoped queue' do
    it 'shows only songs associated with the selected event' do
      event = create(:event, venue: venue)
      included = create(:performance, venue: venue, user: user, performer: 'Included Singer', event: event)
      create(:performance, venue: venue, user: user, performer: 'Venue Singer')

      get venue_event_queue_path(venue.slug, event_slug: event.slug)

      expect(response).to be_successful
      expect(response.body).to include(included.performer)
      expect(response.body).not_to include('Venue Singer')
    end
  end

  describe 'DELETE /venues/:venue_slug/songs/:id' do
    let(:song) { create(:performance, venue: venue, user: user) }

    it 'deletes the song', :critical do
      initial_count = Performance.count
      delete "/#{venue.slug}/songs/#{song.id}"
      
      # For now, just check that something happened
      expect([200, 302]).to include(response.status)
      expect(Performance.count).to be < (initial_count + 1)
    end
  end

  describe 'PATCH /venues/:venue_slug/songs/:id/finish_song' do
    let(:song) { create(:performance, venue: venue, user: user) }

    it 'marks song as finished', :critical do
      # Make user an admin for queue management
      venue.add_admin(user)
      patch "/#{venue.slug}/songs/#{song.id}/finish_song"
      expect(response.status).to be_in([200, 302])
      expect(song.reload.finished).to be_truthy
    end

    it 'returns a JSON success response for player completion' do
      venue.add_admin(user)

      patch "/#{venue.slug}/songs/#{song.id}/finish_song",
            headers: { 'ACCEPT' => 'application/json' }

      expect(response).to have_http_status(:no_content)
      expect(song.reload.finished).to be_truthy
    end

    it 'does not allow a performer to finish a song' do
      patch "/#{venue.slug}/songs/#{song.id}/finish_song"

      expect(response).to redirect_to("/#{venue.slug}/songs")
      expect(song.reload.finished).to be_falsey
    end
  end

  describe 'PATCH /venues/:venue_slug/songs/:id/skip_song' do
    let(:song) { create(:performance, venue: venue, user: user) }

    it 'marks song as skipped', :critical do
      # Make user an admin for queue management
      venue.add_admin(user)
      patch "/#{venue.slug}/songs/#{song.id}/skip_song"
      expect(response.status).to be_in([200, 302])
      expect(song.reload.skipped).to be_truthy
    end

    it 'does not allow a performer to skip a song' do
      patch "/#{venue.slug}/songs/#{song.id}/skip_song"

      expect(response).to redirect_to("/#{venue.slug}/songs")
      expect(song.reload.skipped).to be_falsey
    end
  end

  describe 'PATCH /venues/:venue_slug/songs/:id/pause_song' do
    let!(:first_song) { create(:performance, venue: venue, user: user, updated_at: 2.hours.ago) }
    let!(:song) { create(:performance, venue: venue, user: user, updated_at: 1.hour.ago) }
    let!(:other_song) { create(:performance, venue: venue, user: user, updated_at: 30.minutes.ago) }

    it 'moves a song back in the queue for a host' do
      venue.add_host(user)

      patch "/#{venue.slug}/songs/#{song.id}/pause_song", params: { spots_back: 1 }

      expect(response).to redirect_to("/#{venue.slug}/songs")
      expect(song.reload.postponed).to be(true)
      expect(Performance.unscoped.where(venue_id: venue.id, finished: false, skipped: false).order(:updated_at).pluck(:id)).to eq([first_song.id, other_song.id, song.id])
    end

    it 'does not allow a performer to pause a song' do
      patch "/#{venue.slug}/songs/#{song.id}/pause_song", params: { spots_back: 1 }

      expect(response).to redirect_to("/#{venue.slug}/songs")
      expect(song.reload.postponed).to be(false)
    end
  end

  describe 'PATCH /venues/:venue_slug/songs/:id/unpause_song' do
    let!(:song) { create(:performance, venue: venue, user: user, postponed: true, updated_at: 1.hour.ago) }
    let!(:first_song) { create(:performance, venue: venue, user: user, updated_at: 2.hours.ago) }
    let!(:other_song) { create(:performance, venue: venue, user: user, updated_at: 30.minutes.ago) }

    it 'moves a paused song to the front of the queue for a host' do
      venue.add_host(user)

      patch "/#{venue.slug}/songs/#{song.id}/unpause_song"

      expect(response).to redirect_to("/#{venue.slug}/songs")
      expect(song.reload.postponed).to be(false)
      expect(Performance.unscoped.where(venue_id: venue.id, finished: false, skipped: false).order(:updated_at).pluck(:id)).to eq([song.id, first_song.id, other_song.id])
    end

    it 'does not allow a performer to unpause a song' do
      patch "/#{venue.slug}/songs/#{song.id}/unpause_song"

      expect(response).to redirect_to("/#{venue.slug}/songs")
      expect(song.reload.postponed).to be(true)
    end
  end

  describe 'PATCH /venues/:venue_slug/songs/:id/requeue_song' do
    let(:song) { create(:performance, :finished, venue: venue, user: user, skipped: true, postponed: true) }

    it 'returns an archived song to the active queue for a host' do
      venue.add_host(user)

      patch "/#{venue.slug}/songs/#{song.id}/requeue_song"

      expect(response).to redirect_to("/#{venue.slug}/songs")
      expect(song.reload).to have_attributes(finished: false, skipped: false, postponed: false)
    end

    it 'does not allow a performer to requeue an archived song' do
      patch "/#{venue.slug}/songs/#{song.id}/requeue_song"

      expect(response).to redirect_to("/#{venue.slug}/songs")
      expect(song.reload.finished).to be(true)
    end
  end

  describe 'PATCH /venues/:venue_slug/songs/:id' do
    let(:song) { create(:performance, venue: venue, user: user) }

    it 'updates the song', :critical do
      patch "/#{venue.slug}/songs/#{song.id}", params: { song: { performer: 'Updated Artist' } }
      expect(song.reload.performer).to eq('Updated Artist')
    end
  end

  describe 'GET /venues/:venue_slug/songs/:id' do
    let(:song) { create(:performance, venue: venue, user: user) }

    it 'displays the song', :critical do
      get "/#{venue.slug}/songs/#{song.id}"
      expect(response).to be_successful
    end
  end
end
