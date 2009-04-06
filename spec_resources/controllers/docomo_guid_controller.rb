class DocomoGuidBaseController < ApplicationController
  def link
    render :inline=>%{<%= link_to "linkto" %>}
  end
end

class DocomoGuidAlwaysController < DocomoGuidBaseController
  docomo_guid :always
end

class DocomoGuidDocomoController < DocomoGuidBaseController
  docomo_guid :docomo
end
