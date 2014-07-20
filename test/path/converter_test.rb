require 'light_test_helper'

module MenuMaker
  class PathConverterTest < ActiveSupport::TestCase
    test 'creates a get path from a given string' do
      assert_equal Path.new(:get, '/path'), Path::Converter.convert('/path')
    end

    test 'creates a path from an array' do
      assert_equal Path.new(:post, '/path'), Path::Converter.convert([:post, '/path'])
    end

    test "create path from array assumes GET by default" do
      assert_equal Path.new(:get, '/path'), Path::Converter.convert(['/path'])
    end

    test "create path from array creates an empty path, when given an empty array" do
      assert_equal Path.new(:get, ''), Path::Converter.convert([])
    end

    test "returns back if path is already a Path" do
      path = Path.new :put, '/path'
      assert_equal path, Path::Converter.convert(path)
    end

    test "creates a path from any object which responds to path and method" do
      request = Class.new do
        def path; '/path' end
        def method; 'PUT' end
      end.new

      assert_equal Path.new(:put, '/path'), Path::Converter.convert(request)
    end

    test "fails if can't create path from object which responds to path and method" do
      assert_raise Path::PathError do
        Path::Converter.convert(Object.new)
      end
    end

    test "a Path global conversion method is also available" do
      assert_equal Path.new(:post, '/path'), Path(:post, '/path')
    end
  end
end
