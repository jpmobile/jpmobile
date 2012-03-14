class Admin::TopController < ApplicationController
  def full_path
    render "/template_path/full_path_partial"
  end
end
