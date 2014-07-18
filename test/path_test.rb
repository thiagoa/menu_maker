require 'menu_maker/path'

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

    test 'to_s returns the address' do
      assert_equal '/path', Path.new(:get, '/path').to_s
    end

    test 'creates a get path from a given string' do
      assert_equal Path.new(:get, '/path'), Path.convert('/path')
    end

    test 'creates a path from an array' do
      assert_equal Path.new(:post, '/path'), Path.convert([:post, '/path'])
    end

    test "creates a path from an array assumes get when can't find request method" do
      assert_equal Path.new(:get, '/path'), Path.convert(['/path'])
    end

    test "creates a path from an array on empty array creates empty get path" do
      assert_equal Path.new(:get, ''), Path.convert([])
    end

    test "returns back the path if already a Path" do
      path = Path.new :put, '/path'
      assert_equal path, Path.convert(path)
    end

    test "from_path fails when not a path" do
      assert_raise Path::PathError do
        Path.from_path(Object.new)
      end
    end
  end
end
