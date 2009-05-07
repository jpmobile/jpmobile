class TemplatePathController < ApplicationController
  def index
    @q = params[:q]
  end
end

