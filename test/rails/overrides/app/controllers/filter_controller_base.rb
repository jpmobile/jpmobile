# -*- coding: utf-8 -*-
class FilterControllerBase < ApplicationController
  def abracadabra_utf8
    render plain: "アブラカダブラ"
  end
  def abracadabra_xhtml_utf8
    response.content_type = "application/xhtml+xml"
    render plain: "アブラカダブラ"
  end
  def index
    @q = params[:q]
    render plain: @q
  end
  def index_hankaku
    render plain: 'ｱﾌﾞﾗｶﾀﾞﾌﾞﾗ' == params[:q]
  end
  def index_zenkaku
    render plain: 'アブラカダブラ' == params[:q]
  end
  def empty
    render plain: ""
  end
  def rawdata
    send_data "アブラカダブラ", :type => 'application/octet-stream'
  end
  def textarea
    render plain: '<textarea hoge="fuu">アブラカダブラ</textarea>'
  end
  def input_tag
    render plain: '<input hoge="fuu" value="アブラカダブラ" />'
  end
  def nbsp_char
    render plain: '<a>アブラ&nbsp;カダブラ</a>'
  end
end
