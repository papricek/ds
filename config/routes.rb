Rails.application.routes.draw do
  root "home#index"

  resource :session, path: "prihlaseni", only: [ :new, :create, :destroy ]
  resources :password_resets, path: "obnova-hesla", only: [ :new, :create, :edit, :update ]
  resources :contact_forms, only: [ :new, :create ]

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

  resources :sharings, path: "sdileni", only: [ :index ]

  namespace :manager, path: "sprava" do
    resources :users, path: "uzivatele" do
      scope module: :users do
        resource :profile, only: [ :show ], controller: "profiles", path: "profil"
        resource :details, only: [ :show, :update ], controller: "details", path: "detaily"
        resources :addresses, path: "eany", only: [ :index, :new, :create, :edit, :update, :destroy ]
        resource :user_sharings, only: [ :show ], controller: "sharings", path: "sdileni"
        resource :user_billings, only: [ :show ], controller: "billings", path: "vyuctovani"
        resource :user_settings, only: [ :show ], controller: "settings", path: "nastaveni-uzivatele"
      end
    end
    resources :addresses, path: "adresy"
    resources :groups, path: "skupiny" do
      member do
        post :create_sharings, path: "vytvorit-sdileni"
      end
      resources :group_customers, path: "odberatele", only: [ :create, :destroy ] do
        resources :group_supplier_allocations, path: "alokace", only: [ :create, :destroy ]
      end
    end
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
    resource :help, path: "napoveda", only: [ :show ], controller: "help"
    resource :impersonate_user, path: "prevzit-roli", only: [ :update, :destroy ]
  end

  namespace :superadmin, path: "superadmin", constraints: SuperadminConstraint.new do
    resources :accounts, path: "ucty" do
      resources :users, path: "uzivatele", only: [ :new, :create, :edit, :update, :destroy ]
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
