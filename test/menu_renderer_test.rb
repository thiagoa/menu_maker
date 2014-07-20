require 'light_test_helper'
require 'ostruct'

module MenuMaker
  class MenuRendererTest < ActiveSupport::TestCase
    ChildMenuRenderer = Class.new MenuRenderer do
      render {}
    end

    test "can access context's helper methods" do
      context  = OpenStruct.new helper_method: 'assert_me'
      renderer = ChildMenuRenderer.new(context)

      assert_equal 'assert_me', renderer.helpers.helper_method
    end

    context '#build_html' do
      context 'html_safe is available on strings' do
        should 'call html_safe on returned string' do
          renderer = ChildMenuRenderer.new(proc {})
          output = renderer.build_html do |html|
            OpenStruct.new html_safe: 'I was called'
          end

          assert_equal 'I was called', output
        end
      end

      context "html_safe isn't available on strings" do
        should "not call html_safe" do
          renderer = ChildMenuRenderer.new(proc {})
          stub     = Object.new

          output = renderer.build_html { |_| stub }
          assert_equal stub, output
        end
      end
    end

    test '#build_menu runs the supplied block for each menu item' do
      renderer = ChildMenuRenderer.new(proc {})
      renderer.menu = Menu.new(renderer) do |m|
        m.add 'Item 1', '1'
        m.add 'Item 2', '2'
      end

      items = []

      renderer.build_menu do |item, accumulator|
        items << item
        'should return rendered item string'
      end

      assert_equal %w[1 2], items.map(&:path)
    end

    context 'child renderer rules and functionality' do
      should "fail when not setup with .render class method" do
        child_renderer = Class.new(MenuRenderer).new(proc {})

        assert_raise MenuRenderer::MenuRendererError do
          child_renderer.render
        end
      end

      context '.render class methods responsibilities' do
        should 'define a #render method to force build_html on the output' do
          child_renderer_class = Class.new(MenuRenderer) do
            render { OpenStruct.new html_safe: 'assert_me' }
          end

          child_renderer = child_renderer_class.new(proc {})
          assert_equal 'assert_me', child_renderer.render
        end
      end

      should 'place main logic inside a .render class method block' do
        child_renderer_class = Class.new(MenuRenderer) do
          render { 'render_me' }
        end

        child_renderer = child_renderer_class.new(proc {})
        assert_equal 'render_me', child_renderer.render
      end
    end

    context '#current_path' do
      context 'supplied context has a request' do
        ContextStub = begin
          request_stub = Class.new do
            def method; 'POST'  end
            def path;   '/path' end
          end.new

          OpenStruct.new request: request_stub
        end

        context 'an explicit path is not supplied' do
          should 'get the path from the request' do
            renderer = ChildMenuRenderer.new(ContextStub, nil)
            assert_equal Path.new(:post, '/path'), renderer.current_path
          end
        end

        context 'an explicit path is supplied' do
          should 'not get the path from the request' do
            renderer = ChildMenuRenderer.new(ContextStub, '/other')
            assert_equal Path.new(:get, '/other'), renderer.current_path
          end
        end
      end
    end
  end
end
