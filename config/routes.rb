ReleaseApp::Application.routes.draw do
  resources :applications
  resources :deployments
  resources :releases

  root :to => redirect("/releases", :status => 302)
end
