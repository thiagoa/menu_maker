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
  end
end
