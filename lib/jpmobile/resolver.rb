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

      begin
        template_paths = find_template_paths query
      rescue NoMethodError
        self.class_eval do
          def find_template_paths(query)
            # deals with case-insensitive file systems.
            sanitizer = Hash.new { |h,dir| h[dir] = Dir["#{dir}/*"] }

            Dir[query].reject { |filename|
              File.directory?(filename) ||
                !sanitizer[File.dirname(filename)].include?(filename)
            }
          end
        end

        retry
      end

      template_paths.map { |template|
        handler, format, variant = extract_handler_and_format_and_variant(template, formats)
        contents = File.binread(template)

        if format
          jpmobile_variant = template.match(/.+#{path}(.+)\.#{format.to_sym.to_s}.*$/) ? $1 : ''
          virtual_path = jpmobile_variant.blank? ? path.virtual : path.to_str + jpmobile_variant
        else
          virtual_path = path.virtual
        end

        ActionView::Template.new(contents, File.expand_path(template), handler,
          :virtual_path => virtual_path,
          :format       => format,
          :variant      => variant,
          :updated_at   => mtime(template)
        )
      }
    end
  end
end
