class TransSidBaseController < ApplicationController
  session :session_key => '_session_id'
  def form
    render :inline=>%{<% form_tag do %>Hello<% end %>}
  end
  def link
    render :inline=>%{<%= link_to "linkto" %>}
  end
end

class TransSidAlwaysController < TransSidBaseController
  trans_sid :always
end

class TransSidNoneController < TransSidBaseController
  trans_sid :none
end

class TransSidMobileController < TransSidBaseController
  trans_sid :mobile
end

class TransSidAlwaysAndSessionOffController < TransSidBaseController
  trans_sid :always
  session :off
end
