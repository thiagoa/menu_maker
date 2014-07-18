module MenuMaker
  class Menu
    include Enumerable

    def initialize(renderer)
      @items    = {}
      @renderer = renderer

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
      renderer_for(current_depth).call(self)
    end

    protected

    attr_writer :current_depth

    private

    def current_item
      @items[@current_item]
    end

    def current_submenu
      current_item.submenu || create_submenu!
    end

    def create_submenu!
      submenu = Menu.new renderer_for(next_depth)
      submenu.current_depth = next_depth

      current_item.submenu = submenu
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

    def current_depth
      @current_depth || 1
    end

    def next_depth
      current_depth + 1
    end

    class MenuItem
      attr_reader :title, :options

      def initialize(title, *paths, **options)
        @title   = title
        @paths   = paths.map { |p| Path.convert(p) }
        @options = options
      end

      attr_accessor :submenu

      def has_submenu?
        !@submenu.nil?
      end

      def paths
        @paths.map(&:address)
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
        all_paths.any? { |p| p == path }
      end

      def method_missing(method, *args)
        options && options[method] || ''
      end

      def respond_to_missing?(method)
        !!(options && options[method])
      end

      def path
        @paths.first.address
      end

      def render_submenu
        has_submenu? ? submenu.render : ''
      end

      def to_s
        title
      end
    end

    class MenuError < StandardError; end
  end
end
