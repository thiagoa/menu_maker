require 'test_helper'

module MenuMaker
  class MenuRendererTest < ActiveSupport::TestCase
    def proc_renderer
      proc do |menu|
        items = menu.inject('') do |html, item|
          link  = %{<a href="#{item.path}">#{item}</a>}
          html + %{<li>#{link}#{item.render_submenu}</li>}
        end

        "<ul>#{items}</ul>"
      end
    end

    context 'with a renderer which responds to call' do
      should 'render the menu' do
        menu_maker = Menu.new(proc_renderer) do |menu|
          menu.add 'First link', '/some/path'
        end

        expected = '<ul><li><a href="/some/path">First link</a></li></ul>'
        assert_equal expected, menu_maker.render
      end

      context 'when one renderer is available' do
        should 'render all menu depths with the same renderer' do
          menu_maker = Menu.new(proc_renderer) do |menu|
            menu.add 'First link', '/some/path' do |submenu|
              submenu.add 'First sublink', '/some/path/new'
            end
          end

          submenu  = %{<ul><li><a href="/some/path/new">First sublink</a></li></ul>}
          expected = %{<ul><li><a href="/some/path">First link</a>#{submenu}</li></ul>}

          assert_equal expected, menu_maker.render
        end
      end

      context 'when two renderers are available' do
        should 'render menu depths with respective renderers' do
          submenu_renderer = proc { |menu| '<ul><li>Static</li></ul>' }

          renderer = MenuRendererContainer.new do |container|
            container.add_for_next_depth proc_renderer
            container.add_for_next_depth submenu_renderer
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
end
