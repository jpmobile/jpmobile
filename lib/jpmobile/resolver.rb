module Jpmobile
  class Resolver < ActionView::FileSystemResolver
    EXTENSIONS = [:locale, :formats, :handlers, :mobile].freeze
    DEFAULT_PATTERN = ':prefix/:action{_:mobile,}{.:locale,}{.:formats,}{+:variants,}{.:handlers,}'.freeze

    def initialize(path, pattern = nil)
      raise ArgumentError, 'path already is a Resolver class' if path.is_a?(Resolver)

      super(path, pattern || DEFAULT_PATTERN)
      @path = File.expand_path(path)
    end

    private

    def query(path, details, formats, outside_app_allowed)
      query = build_query(path, details)

      template_paths = find_template_paths(query)
      template_paths = reject_files_external_to_app(template_paths) unless outside_app_allowed

      template_paths.map do |template|
        handler, format, variant = extract_handler_and_format_and_variant(template)
        contents = File.binread(template)

        virtual_path = if format
                         if template =~ /.+#{path}(.+)\.#{format.to_sym.to_s}.*$/
                           path.to_str + Regexp.last_match(1)
                         else
                           path.virtual
                         end
                       else
                         path.virtual
                       end

        ActionView::Template.new(
          contents,
          File.expand_path(template),
          handler,
          virtual_path: virtual_path,
          format: format,
          variant: variant,
          updated_at: mtime(template),
        )
      end
    end
  end
end
