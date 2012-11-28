ReleaseApp::Application.routes.draw do
  resources :applications
  resources :tasks

  root :to => redirect("/applications", :status => 302)
end
