class TemplatePathController < ApplicationController
  def index
    @q = params[:q]

    if params[:pc]
      disable_mobile_view!
    end
  end

  def show
  end

  def optioned_index
    render :action => "index"
  end
end

