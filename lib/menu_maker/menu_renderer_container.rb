module MenuMaker
  class MenuRendererContainer
    def initialize
      @renderers     = {}
      @current_depth = 1

      yield self if block_given?
    end

    def add_for_next_depth(renderer)
      add @current_depth, renderer
      @current_depth += 1;

      self
    end

    def for_depth(depth)
      @renderers[depth]
    end

    private

    def add(depth, renderer)
      @renderers[depth] = renderer
    end
  end
end
