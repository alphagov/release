ReleaseApp::Application.routes.draw do
  resources :applications do
    member do
      put :update_notes
    end
  end
  resources :deployments
  resources :releases

  root :to => redirect("/applications", :status => 302)
end
