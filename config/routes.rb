Rails.application.routes.draw do
  root "sessions#new"

  resource :session, path: "prihlaseni", only: [ :new, :create, :destroy ]
  resources :password_resets, path: "obnova-hesla", only: [ :new, :create, :edit, :update ]

  resources :dashboards, path: "prehled", only: [ :index ]

  resources :billings, path: "vyuctovani", only: [ :index, :show ] do
    member do
      get :download, path: "stahnout"
    end
  end

  resources :addresses, path: "adresy", only: [ :index ]

  namespace :settings, path: "nastaveni" do
    resource :user, path: "uzivatel", only: [ :edit, :update ]
  end

  namespace :manager, path: "sprava" do
    resources :users, path: "uzivatele"
    resources :addresses, path: "adresy"
    resources :groups, path: "skupiny"
    resources :sharings, path: "sdileni"
    resources :billings, path: "vyuctovani" do
      collection do
        get :batch_new, path: "hromadne"
        post :batch_create, path: "hromadne"
        get :export
      end
      member do
        patch :mark_paid, path: "zaplaceno"
        get :download, path: "stahnout"
      end
    end
    resource :settings, path: "nastaveni", only: [ :edit, :update ]
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
