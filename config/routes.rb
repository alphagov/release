ReleaseApp::Application.routes.draw do
  resources :applications do
    collection do
      get 'archived', to: 'applications#archived'
    end

    member do
      patch :update_notes
    end

    member do
      get :deploy
    end

    resources :deployments
  end

  resources :deployments

  get '/activity', to: 'deployments#recent', as: :activity

  get '/healthcheck', to: 'application#healthcheck'

  root to: redirect("/applications", status: 302)

  if Rails.env.development?
    mount GovukAdminTemplate::Engine, at: "/style-guide"
  end
end
