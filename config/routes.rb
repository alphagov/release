ReleaseApp::Application.routes.draw do
  resources :applications
  resources :releases
  resources :tasks

  root :to => redirect("/applications", :status => 302)
end
