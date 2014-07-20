module MenuMaker
  class Menu
    class MenuItem
      attr_reader :title, :paths, :options
      attr_accessor :submenu

      def initialize(title, *paths, **options)
        @title   = title
        @paths   = paths.map { |path| to_path(path) }
        @options = options
      end

      def path
        @paths.first.path
      end

      def has_path?(path)
        all_paths.include? to_path(path)
      end

      def all_paths
        [*paths, *submenu_paths]
      end

      def has_submenu?
        !@submenu.nil?
      end

      def submenu_paths
        return [] unless has_submenu?

        submenu.items.reduce([]) do |paths, item|
          paths + [*item.paths, *item.submenu_paths]
        end
      end

      def render_submenu
        has_submenu? ? submenu.render : ''
      end

      def method_missing(method, *args)
        (options && options[method]) || ''
      end

      def respond_to_missing?(method)
        !!(options && options[method])
      end

      def to_s
        title
      end

      private

      def to_path(path)
        Path::Converter.convert path
      end
    end
  end
end
