RailsRoot::Application.routes.draw do
  resources :users
  namespace :admin do
    resources :users
  end
  match ':controller(/:action(/:id(.:format)))'
end
