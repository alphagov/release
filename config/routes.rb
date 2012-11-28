ReleaseApp::Application.routes.draw do
  resources :applications
  resources :deploys

  root :to => redirect("/applications", :status => 302)
end
