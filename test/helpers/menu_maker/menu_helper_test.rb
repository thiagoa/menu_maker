require 'test_helper'
require 'menu_maker'
require 'integration_helper'

module MenuMaker
  class MenuHelperTest < ActionView::TestCase
    include MenuHelper
    include IntegrationHelper

    test 'menu helper that maps to Menu class' do
      expected_output = menu_fixture(
        suppliers_li_class:  'dropdown active open',
        list_supplier_class: 'active'
      )

      current_output = menu_maker('/cms/suppliers') do |menu|
        menu.add 'Dashboard', '/cms/dashboard', icon: 'fa fa-dashboard'
        menu.add 'Suppliers', '#', icon: 'fa fa-user' do |submenu|
          submenu.add 'Add Supplier',   '/cms/suppliers/new'
          submenu.add 'List Suppliers', '/cms/suppliers'
        end
      end

      assert_equal expected_output, current_output
    end
  end
end
