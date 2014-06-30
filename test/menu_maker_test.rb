require 'test_helper'
require 'menu_maker'
require 'integration_test_helper'

module MenuMaker
  class MenuHelperTest < ActionView::TestCase
    include MenuTestHelper

    test 'outputs the menu with the first li active' do
      expected_output = menu_fixture(
        dashboard_li_class: 'active open',
        suppliers_li_class: 'dropdown'
      )

      assert_equal expected_output, example_menu('/cms/dashboard').render
    end

    test 'outputs the menu with the first li submenu item active' do
      expected_output = menu_fixture(
        suppliers_li_class: 'dropdown active open',
        add_supplier_class: 'active'
      )

      assert_equal expected_output, example_menu('/cms/suppliers/new').render
    end

    test 'outputs the menu with the second li submenu item selected' do
      expected_output = menu_fixture(
        suppliers_li_class: 'dropdown active open',
        list_supplier_class: 'active'
      )

      assert_equal expected_output, example_menu('/cms/suppliers').render
    end
  end
end
