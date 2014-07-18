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

    test "equality works with another Path object" do
      assert_equal Path.new(:put, '/path'), Path.new(:put, '/path')
    end

    test "equality works with a compliant string" do
      assert_equal Path.new(:get, '/path'), '/path'
    end

    test "equality works with a compliant array" do
      assert Path.new(:post, '/path') == [:post, '/path']
    end

    test "equality works with other compliant objects" do
      object = Class.new do
        def path; '/path' end
        def method; 'PUT' end
      end.new

      assert_equal Path.new(:put, '/path'), object
    end
  end
end
