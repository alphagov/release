ReleaseApp::Application.routes.draw do
  resources :applications do
    collection do
      get 'archived', to: 'applications#archived'
    end

    member do
      put :update_notes
    end

    resources :deployments
  end

  resources :deployments
  resources :releases

  get '/activity', to: 'deployments#recent', as: :activity

  root :to => redirect("/applications", :status => 302)
end
