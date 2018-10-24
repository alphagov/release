ReleaseApp::Application.routes.draw do
  resources :applications do
    collection do
      get 'archived', to: 'applications#archived'
    end

    member do
      get :deploy
      get :stats
    end

    resources :deployments
  end

  resources :deployments

  resource :site, only: [:show, :update]

  get '/activity', to: 'deployments#recent', as: :activity

  get '/healthcheck', to: 'application#healthcheck'

  get '/stats', to: 'stats#index'

  root to: redirect("/applications", status: 302)

  if Rails.env.development?
    mount GovukAdminTemplate::Engine, at: "/style-guide"
  end
end
