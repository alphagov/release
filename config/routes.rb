ReleaseApp::Application.routes.draw do
  resources :applications do
    member do
      get :deploy
      get :stats
    end

    resources :deployments
  end

  resources :deployments do
    resource :change_failure
  end

  resource :site, only: %i[show update]

  get "/activity", to: "deployments#recent", as: :activity

  get "/healthcheck/live", to: proc { [200, {}, %w[OK]] }
  get "/healthcheck/ready", to: GovukHealthcheck.rack_response(
    GovukHealthcheck::ActiveRecord,
  )

  get "/stats", to: "stats#index"

  root to: redirect("/applications", status: 302)
end
