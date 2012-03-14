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

    # Helper for building query glob string based on resolver's pattern.
    def build_query(path, details)
      if path.prefix.match(/^\//) and !File.exists?(path.prefix)
        path = Path.build(path.name, File.join(@path, path.prefix), path.partial)
      end

      query = @pattern.dup

      prefix = path.prefix.empty? ? "" : "#{escape_entry(path.prefix)}\\1"
      query.gsub!(/\:prefix(\/)?/, prefix)

      partial = escape_entry(path.partial? ? "_#{path.name}" : path.name)
      query.gsub!(/\:action/, partial)

      details.each do |ext, variants|
        query.gsub!(/\:#{ext}/, "{#{variants.compact.uniq.join(',')}}")
      end

      File.expand_path(query, @path)
    end

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

        if format
          variant = template.match(/.+#{path}(.+)\.#{format.to_sym.to_s}.*$/) ? $1 : ''
          virtual_path = variant.blank? ? nil : path + variant
        else
          virtual_path = path.virtual
        end

        ActionView::Template.new(contents, File.expand_path(template), handler,
          :virtual_path => virtual_path,
          :format       => format,
          :updated_at   => mtime(template))
      }
    end
  end
end
