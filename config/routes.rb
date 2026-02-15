Rails.application.routes.draw do
  #devise_for :users
  devise_scope :user do
    get "/sign_in" => "devise/sessions#new" # custom path to login/sign_in
    get "/sign_up" => "devise/registrations#new", as: "new_user_registration" # custom path to sign_up/registration
  end
  devise_for :users, :skip => [:registrations], 
                     controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
    as :user do
    get 'users/edit' => 'devise/registrations#edit', :as => 'edit_user_registration'
    put 'users' => 'devise/registrations#update', :as => 'user_registration'
  end
  root 'welcome#index'
  resources :songs do
    collection do
      get :youtube_search
      get :validate_video
    end
  end
  get '/finish_song', to: 'songs#finish_song', as: 'finish_song'
  get '/skip_song', to: 'songs#skip_song', as: 'skip_song'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
