module MenuMaker
  module MenuHelper
    def menu_maker(active_path = nil, &block)
      renderers = MenuRendererCollection.new do |collection|
        collection.add(CustomMenuRenderer.new    self, active_path)
        collection.add(CustomSubmenuRenderer.new self, active_path)
      end

      Menu.new(renderers, &block).render
    end

    def li(title, url = nil, options = {})
      link_options = options.fetch(:link, {})
      options.reject! { |k,v| k == :link }

      content = link_to_if(url.present?, title, url, link_options)
      content_tag(:li, content, options).html_safe
    end
  end
end
