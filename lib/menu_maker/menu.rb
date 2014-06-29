module MenuMaker
  class Menu
    include Enumerable

    def initialize(renderer, depth = 1)
      @items         = {}
      @current_depth = depth
      @renderer      = renderer

      yield self if block_given?
    end

    def items
      @items.values
    end

    def each(&block)
      items.each(&block)
    end

    def add(title, path, options = {})
      @items[title] = MenuItem.new(title, path, options)
      @current_item = title

      yield current_submenu if block_given?

      self
    end

    def render
      renderer_for(@current_depth).call(self)
    end

    private

    def current_item
      @items[@current_item]
    end

    def current_submenu
      current_item.submenu ||
        current_item.create_submenu!(
          renderer_for(next_depth), next_depth
        )
    end

    def next_depth
      @current_depth + 1
    end

    def renderer_for(depth)
      renderer = if @renderer.respond_to? :for_depth
        @renderer.for_depth(depth)
      else
        @renderer
      end

      unless renderer.respond_to? :call
        raise MenuError, "Couldn't find renderer for depth #{depth}"
      end

      renderer
    end

    MenuItem = Struct.new(:title, :path, :options) do
      attr_accessor :submenu

      def has_submenu?
        !@submenu.nil?
      end

      def create_submenu!(renderer, depth)
        @submenu = Menu.new(renderer, depth)
      end

      def submenu_paths
        has_submenu? ? submenu.items.map(&:path) : []
      end

      def all_paths
        [path] + submenu_paths
      end

      def has_path?(path)
        all_paths.any? { |p| p == path }
      end

      def method_missing(method, *args)
        options && options[method] || ''
      end

      def respond_to_missing?(method)
        !!(options && options[method])
      end

      def render_submenu
        has_submenu? ? submenu.render : ''
      end
    end

    class MenuError < StandardError; end
  end
end
