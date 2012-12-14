ReleaseApp::Application.routes.draw do
  resources :applications
  resources :releases

  root :to => redirect("/releases", :status => 302)
end
