module MenuMaker
  class MenuRendererCollection
    def initialize
      @renderers     = {}
      @current_depth = 1

      yield self if block_given?
    end

    def add(renderer)
      @renderers[@current_depth] = renderer
      @current_depth += 1;

      self
    end

    def for_depth(depth)
      @renderers[depth]
    end
  end
end
