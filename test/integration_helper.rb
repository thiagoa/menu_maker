module MenuMaker
  module IntegrationHelper
    def menu_fixture(replacements = {})
      replacements.each do |k, v|
        replacements[k] = v.blank? ? '' : %{ class="#{v}"}
      end

      replacement_keys = %i{
        dashboard_li_class
        suppliers_li_class
        add_supplier_class
        list_supplier_class
      }

      output = begin
        path = File.expand_path('../fixtures/menu.html', __FILE__)
        html = File.read path
        html.split("\n").map(&:strip).join('')
      end

      replacement_keys.each { |k| replacements[k] ||= '' }
      replacements.each { |k,v| output.sub!("{#{k}}", v) }

      output
    end

    def example_menu(current_path)
      renderers = MenuRendererCollection.new do |collection|
        collection.add(CustomMenuRenderer.new    self, current_path)
        collection.add(CustomSubmenuRenderer.new self, current_path)
      end

      Menu.new(renderers) do |menu|
        menu.add 'Dashboard', '/cms/dashboard', icon: 'fa fa-dashboard'
        menu.add 'Suppliers', '#', icon: 'fa fa-user' do |submenu|
          submenu.add 'Add Supplier',   '/cms/suppliers/new'
          submenu.add 'List Suppliers', '/cms/suppliers'
        end
      end
    end

    def li(title, url = nil, options = {})
      link_options = options.fetch(:link, {})
      options.reject! { |k,v| k == :link }

      content = link_to_if(url.present?, title, url, link_options)
      content_tag(:li, content, options).html_safe
    end
  end

  class CustomMenuRenderer < MenuRenderer
    render do
      output = build_menu do |item, css_class|
        html = build_html { render_link(item) + item.render_submenu }

        css_class << 'dropdown'    if item.has_submenu?
        css_class << 'active open' if item.has_path? current_path

        options = { class: css_class.join(' ') } if css_class.any?
        h.li(html, nil, options || {})
      end

      h.content_tag(:ul, output, class: 'nav navbar-nav side-nav')
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
