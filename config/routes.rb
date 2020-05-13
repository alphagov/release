ReleaseApp::Application.routes.draw do
  namespace :api, defaults: { format: :json } do
    resources :applications, only: [:show]
  end

  resources :applications do
    collection do
      get "archived", to: "applications#archived"
    end

    member do
      get :deploy
      get :stats
    end

    resources :deployments
  end

  resources :deployments

  resource :site, only: %i[show update]

  get "/activity", to: "deployments#recent", as: :activity

  get "/healthcheck", to: "application#healthcheck"

  get "/stats", to: "stats#index"

  root to: redirect("/applications", status: 302)

  if Rails.env.development?
    mount GovukAdminTemplate::Engine, at: "/style-guide"
  end
end
