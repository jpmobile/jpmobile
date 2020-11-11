module Jpmobile
  class Resolver < ::ActionView::FileSystemResolver
    EXTENSIONS = [:locale, :formats, :handlers, :mobile].freeze
    DEFAULT_PATTERN = ':prefix/:action{_:mobile,}{.:locale,}{.:formats,}{+:variants,}{.:handlers,}'.freeze

    def initialize(path)
      raise ArgumentError, 'path already is a Resolver class' if path.is_a?(Resolver)

      super
      @pattern = DEFAULT_PATTERN
      @path = File.expand_path(path)
    end
  end
end
