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

    def add(title, *paths, **options)
      @items[title] = MenuItem.new(title, *paths, options)
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
      renderer = renderer_for next_depth
      submenu  = Menu.new(renderer)

      current_item.submenu = submenu.tap do |m|
        m.current_depth = next_depth
      end
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

    class MenuError < StandardError; end
  end
end
