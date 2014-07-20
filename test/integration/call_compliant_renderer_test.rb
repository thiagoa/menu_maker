require 'light_test_helper'

module MenuMaker
  class CallCompliantRendererTest < ActiveSupport::TestCase
    ProcRenderer = proc do |menu|
      items = menu.inject('') do |html, item|
        link  = %{<a href="#{item.path}">#{item}</a>}
        html + %{<li>#{link}#{item.render_submenu}</li>}
      end

      "<ul>#{items}</ul>"
    end

    context 'one renderer is supplied for a single-level menu' do
      should 'render the menu' do
        menu_maker = Menu.new(ProcRenderer) do |menu|
          menu.add 'First link', '/some/path'
        end

        expected = '<ul><li><a href="/some/path">First link</a></li></ul>'
        assert_equal expected, menu_maker.render
      end
    end

    context 'one renderer is supplied for a two-level menu' do
      should 'render all depths with the same renderer' do
        menu_maker = Menu.new(ProcRenderer) do |menu|
          menu.add 'First link', '/some/path' do |submenu|
            submenu.add 'First sublink', '/some/path/new'
          end
        end

        submenu  = %{<ul><li><a href="/some/path/new">First sublink</a></li></ul>}
        expected = %{<ul><li><a href="/some/path">First link</a>#{submenu}</li></ul>}

        assert_equal expected, menu_maker.render
      end
    end

    context 'two renderers are supplied for a two level menu' do
      should 'render depths with respective renderers' do
        submenu_renderer = proc { |menu| '<ul><li>Static</li></ul>' }

        renderer = MenuRendererCollection.new do |collection|
          collection.add ProcRenderer
          collection.add submenu_renderer
        end

        menu_maker = Menu.new(renderer) do |menu|
          menu.add 'First link', '/some/path' do |submenu|
            submenu.add 'First sublink', '/some/path/new'
          end
        end

        submenu  = "<ul><li>Static</li></ul>"
        expected = %{<ul><li><a href="/some/path">First link</a>#{submenu}</li></ul>}

        assert_equal expected, menu_maker.render
      end
    end
  end
end
