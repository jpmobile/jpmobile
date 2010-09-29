# -*- coding: utf-8 -*-
class FilterControllerBase < ApplicationController
  def abracadabra_utf8
    render :text => "アブラカダブラ"
  end
  def abracadabra_xhtml_utf8
    response.content_type = "application/xhtml+xml"
    render :text => "アブラカダブラ"
  end
  def index
    @q = params[:q]
  end
  def empty
    render :text => ""
  end
  def rawdata
    send_data "アブラカダブラ", :type => 'application/octet-stream'
  end
  def textarea
    render :text => '<textarea hoge="fuu">アブラカダブラ</textarea>'
  end
  def input_tag
    render :text => '<input hoge="fuu" value="アブラカダブラ" />'
  end
end
