ReleaseApp::Application.routes.draw do
  resources :applications
  resources :releases
  resources :tasks

  match "applications/:id/tags" => "applications#tags"

  root :to => redirect("/releases", :status => 302)
end
