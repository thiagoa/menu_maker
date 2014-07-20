require 'test_helper'
require_relative '../../../app/helpers/menu_maker/menu_helper.rb'

module MenuMaker
  class MenuHelperTest < ActionView::TestCase
    include MenuHelper

    test 'menu helper maps to Menu class' do
      output = menu_maker('/cms/suppliers') do |menu|
        menu.add 'Dashboard', '/dashboard'
      end

      expected = %{<ul><li><a href="/dashboard">Dashboard</a></li></ul>}

      assert_equal expected, output
    end
  end
end
