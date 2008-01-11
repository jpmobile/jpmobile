class FilterController < ApplicationController
  mobile_filter
  def aiu_utf8
    render :text => "あいう"
  end
  def index
    @q = params[:q]
  end
end
