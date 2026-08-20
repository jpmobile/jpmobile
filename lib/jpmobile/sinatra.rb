module Jpmobile
  module Sinatra
    class Base < ::Sinatra::Base
      class VariantViews
        def initialize(views, variants)
          @path = views.respond_to?(:to_path) ? views.to_path : views.to_s
          @variants = variants
        end

        def to_path
          path
        end

        alias_method :to_str, :to_path

        def hash
          [path, variants].hash
        end

        def eql?(other)
          other.is_a?(self.class) && path.eql?(other.path) && variants.eql?(other.variants)
        end

        protected

        attr_reader :path, :variants
      end
      private_constant :VariantViews

      def render(engine, data, options = {}, locals = {}, &)
        variants = env['rack.jpmobile']&.variants
        # Sinatra caches symbol templates without including the path selected by find_template.
        if variants&.any?
          views = options.fetch(:views) { settings.views || './views' }
          options = options.merge(views: VariantViews.new(views, variants.dup.freeze))
        end
        super
      end

      # Calls the given block for every possible template file in views,
      # named name.ext, where ext is registered on engine.
      def find_template(views, name, engine)
        if env['rack.jpmobile'] && !env['rack.jpmobile'].variants.empty?
          env['rack.jpmobile'].variants.each do |variant|
            yield ::File.join(views, "#{name}_#{variant}.#{@preferred_extension}")
          end
        end
        super
      end
    end
  end
end
