module MenuMaker
  class CustomSubmenuRenderer < MenuRenderer
    render do
      output = build_menu do |item|
        options = { link: { class: 'active' } } if item.has_path? current_path
        h.li(item.title, item.path, options || {})
      end

      h.content_tag(:ul, output, class: 'dropdown-menu')
    end
  end
end
