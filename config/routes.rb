Taxa::Application.routes.draw do
  get '/site/about', :to => 'site#about', :as => :about
  get '/user/logout', :to => 'user#logout', :as => :logout
  get '/user/login', :to => 'user#show_login', :as => :show_login
  post '/user/login', :to => 'user#login', :as => :login

  resources :users
  resources :features, only: [:create, :update, :destroy]

  put 'occurrences/exchange' => 'occurrences#exchange', :as => :exchange_occurrences
  put 'occurrences/decrease_quantity' => 'occurrences#decrease_quantity', :as => :decrease_occurrences
  put 'occurrences/increase_quantity' => 'occurrences#increase_quantity', :as => :increase_occurrences
  put 'occurrences/set_quantity' => 'occurrences#set_quantity', :as => :set_quantity
  put 'occurrences/set_status' => 'occurrences#set_status', :as => :set_status
  put 'occurrences/set_uncertain' => 'occurrences#set_uncertain', :as => :set_uncertain

  resources :account_participations, :only => [:index, :create, :destroy]
  resources :research_participations, :only => [:show, :create, :destroy]

  resources :regions do
    resources :wells, :only => [:index, :new]
    resources :countings, :only => :new
    resources :research_participations, :only => [:new]
  end

  resources :countings, :except => :new do
    member do
      get :species
    end
  end

  resources :wells, :except => :new do
    resources :samples, :only => [:index, :new]
  end

  resources :samples, :except => :new

  get 'countings/:counting_id/samples/:sample_id/occurrences' => 'occurrences#index', :as => :counting_sample_occurrences
  get 'countings/:counting_id/samples/:sample_id/occurrences/edit' => 'occurrences#count', :as => :edit_counting_sample_occurrences
  get 'countings/:counting_id/samples/:sample_id/occurrences/available' => 'occurrences#available', :as => :available_counting_sample_occurrences
  resources :occurrences

  resources :reports, :only => [:new, :create]
  post  '/reports/export/:name' => 'reports#export', :as => :report_export

  resources :specimens do
    collection do
      get :search
    end
    resources :images
    resources :comments
  end

  resources :images do
    resources :comments
  end

  resources :comments

  root :to => 'site#index'
end

