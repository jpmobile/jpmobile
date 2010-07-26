class HankakuFilterController < FilterControllerBase
  mobile_filter :hankaku => true
  around_filter :freeze_body

  private
  def freeze_body
    yield
    if response.body.respond_to?(:freeze)
      response.body.freeze
    end
  end
end
