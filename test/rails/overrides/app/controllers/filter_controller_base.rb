class FilterControllerBase < ApplicationController
  def abracadabra_utf8
    @text = 'アブラカダブラ'
    render 'filter/text_template'
  end

  def abracadabra_xhtml_utf8
    response.content_type = 'application/xhtml+xml'
    @text = 'アブラカダブラ'
    render 'filter/text_template'
  end

  def index
    @q = params[:q]
    render plain: @q
  end

  def index_hankaku
    render plain: params[:q] == 'ｱﾌﾞﾗｶﾀﾞﾌﾞﾗ'
  end

  def index_zenkaku
    render plain: params[:q] == 'アブラカダブラ'
  end

  def empty
    render plain: ''
  end

  def rawdata
    send_data 'アブラカダブラ', type: 'application/octet-stream'
  end

  def textarea
    @text = '<textarea hoge="fuu">アブラカダブラ</textarea>'.html_safe
    render 'filter/text_template'
  end

  def input_tag
    @text = '<input hoge="fuu" value="アブラカダブラ" />'.html_safe
    render 'filter/text_template'
  end

  def nbsp_char
    @text = '<a>アブラ&nbsp;カダブラ</a>'.html_safe
    render 'filter/text_template'
  end
end
