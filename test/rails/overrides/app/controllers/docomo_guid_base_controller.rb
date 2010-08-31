class DocomoGuidBaseController < ApplicationController
  def link
    render :inline=>%{<%= link_to "linkto" %>}
  end
end
