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
end

class FilterController < FilterControllerBase
  mobile_filter
end

class HankakuFilterController < FilterControllerBase
  mobile_filter :hankaku => true

  around_filter :freeze_response_body

  private
  def freeze_response_body
    yield
    if response.body.respond_to?(:freeze)
      response.body.freeze
    end
  end
end
