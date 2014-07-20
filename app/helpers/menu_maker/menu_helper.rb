module MenuMaker
  module MenuHelper
    def menu_maker(active_path = nil, &block)
      renderer = DefaultMenuRenderer.new(self, active_path)
      Menu.new(renderer, &block).render
    end
  end
end
