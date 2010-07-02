# -*- coding: utf-8 -*-
class TransSidBaseController < ApplicationController
  # 事前にセッションを作成しないと trans_sid が有効にならない
  before_filter :session_init

  def form
    render :inline=>%{<%= form_tag do %>Hello<% end %>}
  end
  def link
    render :inline=>%{<%= link_to "linkto" %>}
  end
  def redirect
    redirect_to('/')
  end
  def session_init
    session[:jpmobile] = "everyleaf"
  end
end
