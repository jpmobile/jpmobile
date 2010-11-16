class HankakuInputFilterController < FilterControllerBase
  hankaku_filter :input => true

  def index_xhtml
    render "index_xhtml", :layout => "xhtml"
  end
end
