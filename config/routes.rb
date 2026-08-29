Rails.application.routes.draw do
  #devise_for :users
  devise_scope :user do
    get "/sign_in" => "users/sessions#new" # custom path to login/sign_in
    get "/sign_up" => "users/registrations#new", as: "new_user_registration" # custom path to sign_up/registration
  end
  devise_for :users, :skip => [:registrations], 
                     controllers: {
                       sessions: 'users/sessions',
                       registrations: 'users/registrations',
                       omniauth_callbacks: 'users/omniauth_callbacks'
                     }
  as :user do
    get 'users/edit' => 'devise/registrations#edit', :as => 'edit_user_registration'
    post 'users' => 'users/registrations#create', :as => 'create_user_registration'
    put 'users' => 'devise/registrations#update', :as => 'user_registration'
  end
  
  root 'welcome#index'
  
  # Venue discovery
  get '/discover', to: 'venues#discover', as: 'discover_venues'
  get '/help', to: 'help#index', as: :help
  get '/venues/presence/:token', to: 'presence#venue', as: :venue_presence
  get '/event-presence/code', to: 'presence#event_code', as: :event_presence_code
  get '/event-presence/:token', to: 'presence#event', as: :event_presence
  post '/venues/join/:slug', to: 'venues#join', as: 'join_venue'
  get '/host-invitations/:token', to: 'venue_invitations#show', as: 'venue_invitation'
  
  # Venue-scoped routes by slug
  scope '/:venue_slug', as: 'venue' do
    # Songs (queue management)
    resources :songs do
      collection do
        get :youtube_search
        get :validate_video
      end
      member do
        patch :start_song
        patch :stop_song
        patch :finish_song
        patch :pause_song
        patch :unpause_song
        patch :requeue_song
        patch :review_theme
        patch :skip_song
      end
    end
    
    # Venue settings (owner only)
    get '/settings', to: 'venues#settings', as: 'settings'
    patch '/settings', to: 'venues#update_settings'
    
    # Admin management (owner only)
    post '/admins', to: 'venues#create_admin', as: 'admins'
    delete '/admins/:id', to: 'venues#destroy_admin', as: 'admin'

    resources :events, param: :slug, except: :edit do
      member do
        patch :start
        patch :complete
      end
    end
    match '/events/:event_slug/queue', to: 'songs#index', via: :get, as: 'event_queue'
    get '/events/:event_slug/presentation', to: 'songs#presentation', as: 'event_presentation'
    get '/events/:event_slug/queue/state', to: 'songs#queue_state', as: 'event_queue_state'
    post '/events/:event_slug/queue', to: 'songs#create'
    resources :event_host_delegations, only: %i[create destroy]
    resources :event_presence_sessions, only: %i[create destroy]
    resources :themes, except: :show
    resources :event_theme_applications, only: %i[create destroy]
    resources :event_series, path: 'event-series', except: :show do
      post :generate_occurrences, on: :member
    end
  end
  
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
