module Jpmobile
  class Configuration
    include Singleton

    attr_accessor :fallback_view_selector

    def initialize
      @fallback_view_selector = false
    end

    module RailsConfiguration
      def jpmobile
        @jpmobile ||= ::Jpmobile.config
      end
    end
  end
end
