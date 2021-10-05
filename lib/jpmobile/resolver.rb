module Jpmobile
  class Resolver < ::ActionView::FileSystemResolver
    def initialize(path)
      super(path)

      @path_parser = Jpmobile::Resolver::PathParser.new
    end

    def clear_cache
      super

      @path_parser = Jpmobile::Resolver::PathParser.new
    end

    class PathParser < ::ActionView::Resolver::PathParser
      def build_path_regex
        handlers = ::ActionView::Template::Handlers.extensions.map { |x| Regexp.escape(x) }.join("|")
        formats = ::ActionView::Template::Types.symbols.map { |x| Regexp.escape(x) }.join("|")
        locales = "[a-z]{2}(?:-[A-Z]{2})?"
        variants = "[^.]*"
        mobile = Jpmobile::Mobile.all_variants.map { |x| Regexp.escape(x) }.join("|")

        %r{
          \A
          (?:(?<prefix>.*)/)?
          (?<partial>_)?
          (?<action>.*?)
          (?:_(?<mobile>#{mobile}))??
          (?:\.(?<locale>#{locales}))??
          (?:\.(?<format>#{formats}))??
          (?:\+(?<variant>#{variants}))??
          (?:\.(?<handler>#{handlers}))?
          \z
        }x
      end

      def parse(path)
        @regex ||= build_path_regex
        match = @regex.match(path)
        path = ActionView::TemplatePath.build(match[:action], match[:prefix] || "", !!match[:partial])
        details = Jpmobile::TemplateDetails.new(
          match[:locale]&.to_sym,
          match[:handler]&.to_sym,
          match[:format]&.to_sym,
          match[:variant]&.to_sym,
          match[:mobile]&.to_sym,
        )
        ParsedPath.new(path, details)
      end
    end
  end
end
