require 'test_helper'

module MenuMaker
  class PathTest < ActionView::TestCase
    test 'accepts get, post, put, patch and delete' do
      %i[get post put patch delete].each do |method|
        Path.new method, '/path'
      end
    end

    test "doesn't accept a method other than get, post, put, patch and delete" do
      assert_raise Path::PathError do
        Path.new :ouch, '/path'
      end
    end

    test 'to_s returns the path string' do
      assert_equal '/path', Path.new(:get, '/path').to_s
    end

    test 'creates a get path from a given string' do
      assert_equal Path.new(:get, '/path'), Path::Converter.convert('/path')
    end

    test 'creates a path from an array' do
      assert_equal Path.new(:post, '/path'), Path::Converter.convert([:post, '/path'])
    end

    test "creates a path from an array assumes get when can't find request method" do
      assert_equal Path.new(:get, '/path'), Path::Converter.convert(['/path'])
    end

    test "creates a path from an array on empty array creates empty get path" do
      assert_equal Path.new(:get, ''), Path::Converter.convert([])
    end

    test "returns back the path if already a Path" do
      path = Path.new :put, '/path'
      assert_equal path, Path::Converter.convert(path)
    end

    test "creates a path from an object wich responds to path and method" do
      request = Class.new do
        def path
          '/path'
        end

        def method
          'PUT'
        end
      end.new

      assert_equal Path.new(:put, '/path'), Path::Converter.convert(request)
    end

    test "fails if can't create path from object which responds to path and method" do
      assert_raise Path::PathError do
        Path::Converter.convert(Object.new)
      end
    end

    test "equality works with an equal path" do
      assert_equal Path.new(:put, '/path'), Path.new(:put, '/path')
    end

    test "equality works with a convertible string" do
      assert_equal Path.new(:get, '/path'), '/path'
    end

    test "equality works with a convertible array" do
      assert Path.new(:post, '/path') == [:post, '/path']
    end

    test "a Path global conversion method is also available" do
      assert_equal Path.new(:post, '/path'), Path(:post, '/path')
    end
  end
end
