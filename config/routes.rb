Taxa::Application.routes.draw do
  get '/user/logout', :to => 'user#logout', :as => :logout
  get '/user/login', :to => 'user#show_login', :as => :show_login
  post '/user/login', :to => 'user#login', :as => :login

  resources :users
  resources :features, only: [:create, :update, :destroy]

  put 'occurrences/exchange' => 'occurrences#exchange', :as => :exchange_occurrences
  get 'occurrences/:counting_id/:sample_id/stats' => 'occurrences#stats', :as => :stats

  resources :account_participations, :only => [:index, :create, :destroy]
  resources :research_participations, :only => [:show, :create, :destroy]

  resources :projects do
    resources :sections, :only => [:index, :new]
    resources :countings, :only => :new
    resources :research_participations, :only => [:new]
  end

  resources :countings, :except => :new do
    member do
      get :species
    end
  end

  resources :sections, :except => :new do
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

  root to: 'site#index'
end

