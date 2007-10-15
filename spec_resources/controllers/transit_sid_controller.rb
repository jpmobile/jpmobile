class TransitSidBaseController < ApplicationController
  session :session_key => '_session_id'
  def form
    render :inline=>%{<% form_tag do %>Hello<% end %>}
  end
  def link
    render :inline=>%{<%= link_to "linkto" %>}
  end
end

class TransitSidAlwaysController < TransitSidBaseController
  transit_sid :always
end

class TransitSidNoneController < TransitSidBaseController
  transit_sid :none
end

class TransitSidMobileController < TransitSidBaseController
  transit_sid :mobile
end

class TransitSidAlwaysAndSessionOffController < TransitSidBaseController
  transit_sid :always
  session :off
end
