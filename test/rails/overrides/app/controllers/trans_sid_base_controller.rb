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
    @user = User.find(1) rescue User.create(:id => 1, :name => "everyleaf")
  end

  def form_path
    render :inline=>%{<%= form_for @user do %>Hello<% end %>}
  end
  def form_path_admin
    render :inline=>%{<%= form_for [:admin, @user] do %>Hello<% end %>}
  end

  def link_path
    render :inline => %{<%= link_to "linkto", @user -%>}
  end
  def link_path_admin
    render :inline => %{<%= link_to "linkto", [:admin, @user] -%>}
  end

  def redirect_path
    redirect_to @user
  end
  def redirect_path_admin
    redirect_to [:admin, @user]
  end
end
