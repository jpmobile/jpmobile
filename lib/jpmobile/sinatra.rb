module Jpmobile
  module Sinatra
    class Base < ::Sinatra::Base
      # Calls the given block for every possible template file in views,
      # named name.ext, where ext is registered on engine.
      def find_template(views, name, engine)
        if env['rack.jpmobile'] and !env['rack.jpmobile'].variants.empty?
          env['rack.jpmobile'].variants.each do |variant|
            yield ::File.join(views, "#{name}_#{variant}.#{@preferred_extension}")
          end
        end
        super
      end
    end
  end
end
