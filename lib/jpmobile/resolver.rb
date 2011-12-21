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
      templates = []
      sanitizer = Hash.new { |h,k| h[k] = Dir["#{File.dirname(k)}/*"] }

      Dir[query].each do |p|
        next if File.directory?(p) || !sanitizer[p].include?(p)

        handler, format = extract_handler_and_format(p, formats)
        contents = File.open(p, "rb") { |io| io.read }
        variant = p.match(/.+#{path}(.+)\.#{format.to_sym.to_s}.*$/) ? $1 : ''

        templates << ActionView::Template.new(contents, File.expand_path(p), handler,
          :virtual_path => path.name + variant, :format => format, :updated_at => mtime(p))
      end

      templates
    end
  end
end
