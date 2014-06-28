module MenuMaker
  class CustomSubmenuRenderer < MenuRenderer
    render do
      output = build_menu do |item|
        options = if item.path == current_path
          { link: { class: 'active' } }
        else
          {}
        end

        h.li(item.title, item.path, options)
      end

      h.content_tag(:ul, output, class: 'dropdown-menu')
    end
  end
end
