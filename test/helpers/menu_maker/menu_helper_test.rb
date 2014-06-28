require 'test_helper'
require 'menu_maker'
require 'integration_test_helper'
require File.expand_path('../../../../app/helpers/menu_maker/menu_helper', __FILE__)

module MenuMaker
  class MenuHelperTest < ActionView::TestCase
    include MenuTestHelper
    include MenuHelper

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
