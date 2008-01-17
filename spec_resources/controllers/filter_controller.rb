class FilterController < ApplicationController
  mobile_filter
  def abracadabra_utf8
    render :text => "アブラカダブラ"
  end
  def index
    @q = params[:q]
  end
  def rawdata
    send_data "アブラカダブラ", :type => 'application/octet-stream'
  end
end
