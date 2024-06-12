module Jpmobile
  class PathSet < ActionView::PathSet
    private

    def typecast(paths)
      paths.map do |path|
        case path
        when Pathname, String
          Jpmobile::Resolver.new path.to_s
        else
          super
        end
      end
    end
  end
end
