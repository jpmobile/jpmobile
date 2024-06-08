module Jpmobile
  module HookTemplateDetailsRequested
    attr_reader :mobile, :mobile_idx

    def initialize(locale:, handlers:, formats:, variants:, mobile:)
      super(locale:, handlers:, formats:, variants:)

      @mobile = mobile.map(&:to_sym)
      @mobile_idx = build_idx_hash(@mobile)
    end
  end
end
