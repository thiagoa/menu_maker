module MenuMaker
  class CustomMenuRenderer < MenuRenderer
    render do
      out = build_menu do |item, css_class|
        output = build_html do |html|
          html << render_link(item)
          html << item.render_submenu
        end

        css_class << 'dropdown'    if item.has_submenu?
        css_class << 'active open' if item.has_path? current_path

        options = { class: css_class.join(' ') } if css_class.any?
        h.li(output, nil, options || {})
      end

      h.content_tag(:ul, out, class: 'nav navbar-nav side-nav')
    end

    private

    def render_title(item)
      build_html do
        caret = item.has_submenu? ? ' <b class="caret"></b>' : ''
        i = %{<i class="#{item.icon}"></i>}

        "#{i} #{item.title}#{caret}"
      end
    end

    def render_link(item)
      if item.has_submenu?
        options = { class: 'dropdown-toggle', data: { toggle: 'dropdown' } }
      end

      h.link_to(render_title(item), item.path, options || {})
    end
  end
end
