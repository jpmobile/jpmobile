class MobileSpecController < ApplicationController
  include Jpmobile::ViewSelector

  def index
  end

  def file_render
    render :file => File.join(Rails.public_path, '422')
  end

  def no_mobile
  end
end
