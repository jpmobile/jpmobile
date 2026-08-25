RailsRoot::Application.routes.draw do
  resources :users
  namespace :admin do
    resources :users

    controller :top do
      get 'top/full_path', to: 'top#full_path'
    end
  end

  # get ':controller(/:action(/:id(.:format)))'

  %w[
    index
    file_render
    mobile_not_exist
  ].each do |a|
    get "mobile_spec/#{a}", to: "mobile_spec##{a}"
  end

  %w[
    index
    show
    optioned_index
    full_path_partial
    smart_phone_only
    with_tblt
    with_ipd
    partial
    partial_only
  ].each do |a|
    get "template_path/#{a}", to: "template_path##{a}"
  end

  get 'method_less_action_support', to: 'method_less_action_support#index'
end
