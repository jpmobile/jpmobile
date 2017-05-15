RailsRoot::Application.routes.draw do
  resources :users
  namespace :admin do
    resources :users

    controller :top do
      get 'top/full_path', to: 'top#full_path'
    end
  end

  # get ':controller(/:action(/:id(.:format)))'

  get 'trans_sid_metal/redirect', to: 'trans_sid_metal#redirect'

  %w[
    trans_sid_base
    trans_sid_always_and_session_off
    trans_sid_always
    trans_sid_metal
    trans_sid_mobile
    trans_sid_none
  ].each do |c|
    %w[
      form
      link
      redirect
      form_path
      form_path_admin
      link_path
      link_path_admin
      redirect_path
      redirect_path_admin
      redirect_action
    ].each do |a|
      get "#{c}/#{a}", to: "#{c}##{a}"
    end
  end

  %w[
    docomo_guid_base
    docomo_guid_always
    docomo_guid_docomo
  ].each do |c|
    get "#{c}/link", to: "#{c}#link"
  end

  %w[
    show_all
    link
    docomo_utn
    docomo_openiarea
    docomo_foma_gps
    au_location
    au_gps
    softbank_location
    willcom_location
  ].each do |a|
    get "links/#{a}", to: "links##{a}"
  end

  %w[
    index
    file_render
    no_mobile
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
  ].each do |a|
    get "template_path/#{a}", to: "template_path##{a}"
  end

  %w[
    filter
    hankaku_filter
    hankaku_input_filter
  ].each do |c|
    %w[
      abracadabra_utf8
      abracadabra_xhtml_utf8
      index
      index_hankaku
      index_zenkaku
      empty
      rawdata
      textarea
      input_tag
      nbsp_char
      index_xhtml
      with_charset
    ].each do |a|
      get "#{c}/#{a}", to: "#{c}##{a}"
    end
  end
end
