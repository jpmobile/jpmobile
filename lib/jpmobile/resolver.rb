module Jpmobile
  class Resolver < ActionView::FileSystemResolver

    def find_templates(name, prefix, partial, details)
      path = build_path(name, prefix, partial, details)
      extensions = defined?(EXTENSION_ORDER) ? EXTENSION_ORDER : EXTENSIONS
      query(path, extensions.map { |ext| details[ext] }, details[:formats], details[:mobile])
    end

    def build_path(name, prefix, partial, details)
      path = ""
      path << "#{prefix}/" unless prefix.empty?
      path << (partial ? "_#{name}" : name)
      path
    end

    def query(path, exts, formats, mobile)
      query = File.join(@path, path)
      query << '{' << mobile.map {|v| "_#{v}"}.join(',') << ',}' if mobile and mobile.respond_to?(:map)

      exts.each do |ext|
        query << '{' << ext.map {|e| e && ".#{e}" }.join(',') << ',}'
      end

      query.gsub!(/\{\.html,/, "{.html,.text.html,")
      query.gsub!(/\{\.text,/, "{.text,.text.plain,")

      Dir[query].reject { |p| File.directory?(p) }.map do |p|
        handler, format = extract_handler_and_format(p, formats)

        contents = File.open(p, "rb") {|io| io.read }

        ActionView::Template.new(contents, File.expand_path(p), handler,
          :virtual_path => path, :format => format)
      end
    end
  end
end
