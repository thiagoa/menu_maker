require 'light_test_helper'

module MenuMaker
  class DefaultMenuRendererTest < ActiveSupport::TestCase
    test 'renders a menu' do
      renderer = DefaultMenuRenderer.new

      menu = Menu.new(renderer) do |m|
        m.add 'One', '/one'
        m.add 'Two', '/two'
      end

      expected =  '<ul>';
      expected += '<li><a href="/one">One</a></li>'
      expected += '<li><a href="/two">Two</a></li>'
      expected += '</ul>'

      assert_equal menu.render, expected
    end

    test 'renders the menu with a selected item' do
      renderer = DefaultMenuRenderer.new(nil, '/two')

      menu = Menu.new(renderer) do |m|
        m.add 'One', '/one'
        m.add 'Two', '/two'
      end

      expected =  '<ul>';
      expected += '<li><a href="/one">One</a></li>'
      expected += '<li class="active"><a href="/two">Two</a></li>'
      expected += '</ul>'

      assert_equal menu.render, expected
    end
  end
end
