module Jpmobile
  module MethodLessActionSupport
    def template_exists?(*args, **kwargs, &block)
      super(
        *args,
        **kwargs.reverse_merge(mobile: request.mobile&.variants || []),
        &block
      )
    end
  end
end
