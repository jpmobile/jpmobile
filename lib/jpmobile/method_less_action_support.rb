module Jpmobile
  module MethodLessActionSupport
    def template_exists?(*, **kwargs, &)
      super(
        *,
        **kwargs.reverse_merge(mobile: request.mobile&.variants || []),
        &
      )
    end
  end
end
