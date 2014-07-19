module MenuMaker
  module MenuTestHelper
    private

    def menu_definition
      Proc.new do |menu|
        menu.add 'Dashboard', '/cms/dashboard', icon: 'fa fa-dashboard'
        menu.add 'Suppliers', '#', icon: 'fa fa-user' do |submenu|
          submenu.add 'Add Supplier',   '/cms/suppliers/new'
          submenu.add 'List Suppliers', '/cms/suppliers'
        end
      end
    end

    def example_menu(url)
      renderers = MenuRendererCollection.new do |collection|
        collection.add(CustomMenuRenderer.new    self, url)
        collection.add(CustomSubmenuRenderer.new self, url)
      end

      Menu.new(renderers, &menu_definition)
    end

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

      output = raw_menu_html
      replacement_keys.each { |k| replacements[k] ||= '' }
      replacements.each { |k,v| output.sub!("{#{k}}", v) }

      output
    end

    def raw_menu_html
      path = File.expand_path('../fixtures/menu.html', __FILE__)
      html = File.read path
      html.split("\n").map(&:strip).join('')
    end
  end
end
