RailsRoot::Application.routes.draw do
  resources :users
  namespace :admin do
    resources :users

    controller :top do
      get 'top/:action'
    end
  end
  get ':controller(/:action(/:id(.:format)))'
end
