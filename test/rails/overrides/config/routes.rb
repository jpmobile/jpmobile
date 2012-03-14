RailsRoot::Application.routes.draw do
  resources :users
  namespace :admin do
    resources :users

    controller :top do
      match 'top/:action'
    end
  end
  match ':controller(/:action(/:id(.:format)))'
end
