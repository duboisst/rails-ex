Rails.application.routes.draw do
  resources :thoughts
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  scope "" do

    # News - page principale
      resources :news, :only => :index
      root :to => "news#index"
  
      get '/static/:path', :to => 'static#index'
  
  
      resources :bons, :only => :index
      resource :bon, :only => :show
      resources :logs, :only => :show
      get "/logs", :to => "logs#show"
  
  
      resource :sessions, :only => [:new, :create, :destroy]
      resources :contacts, :only => :index
  
      resource :maintenance, :only => :show
      namespace :admin do
        resources :contacts do
          get :index
        end
  
        resources :channels do
          get :index
        end
  
        resources :profiles do
          get :index
        end
  
        resources :users do
          get :index
        end
  
        resources :ldap_users, :only => [:index, :new]
        resource :maintenance, :only => [:edit, :update]
      end
  
    end
end
