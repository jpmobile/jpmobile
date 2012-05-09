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

  def full_path_partial
  end

  def smart_phone_only
  end

  def with_tblt
  end

  def with_ipd
  end
end

