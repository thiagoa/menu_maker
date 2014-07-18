module MenuMaker
  class Menu
    class MenuItem
      attr_reader :title, :options

      def initialize(title, *paths, **options)
        @title   = title
        @paths   = paths.map { |p| Path::Converter.convert(p) }
        @options = options
      end

      attr_accessor :submenu

      def has_submenu?
        !@submenu.nil?
      end

      def paths
        @paths
      end

      def submenu_paths
        return [] unless has_submenu?

        submenu.items.reduce([]) do |all, item|
          all + item.paths + item.submenu_paths
        end.flatten
      end

      def all_paths
        [*paths, *submenu_paths]
      end

      def has_path?(path)
        all_paths.include? Path::Converter.convert(path)
      end

      def method_missing(method, *args)
        options && options[method] || ''
      end

      def respond_to_missing?(method)
        !!(options && options[method])
      end

      def path
        @paths.first.path
      end

      def render_submenu
        has_submenu? ? submenu.render : ''
      end

      def to_s
        title
      end
    end
  end
end
