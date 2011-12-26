module Jpmobile
  class Resolver < ActionView::FileSystemResolver
    EXTENSIONS = [:locale, :formats, :handlers, :mobile]
    DEFAULT_PATTERN = ":prefix/:action{_:mobile,}{.:locale,}{.:formats,}{.:handlers,}"

    def initialize(path, pattern=nil)
      raise ArgumentError, "path already is a Resolver class" if path.is_a?(Resolver)
      super(path, pattern || DEFAULT_PATTERN)
      @path = File.expand_path(path)
    end

    private

    def query(path, details, formats)
      query = build_query(path, details)

      # deals with case-insensitive file systems.
      sanitizer = Hash.new { |h,dir| h[dir] = Dir["#{dir}/*"] }

      template_paths = Dir[query].reject { |filename|
        File.directory?(filename) ||
          !sanitizer[File.dirname(filename)].include?(filename)
      }

      template_paths.map { |template|
        handler, format = extract_handler_and_format(template, formats)
        contents = File.binread template

        variant = template.match(/.+#{path}(.+)\.#{format.to_sym.to_s}.*$/) ? $1 : ''
        virtual_path = variant.blank? ? nil : path + variant

        ActionView::Template.new(contents, File.expand_path(template), handler,
          :virtual_path => virtual_path,
          :format       => format,
          :updated_at   => mtime(template))
      }
    end
  end
end
