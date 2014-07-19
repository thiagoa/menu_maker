module MenuMaker
  class MenuTest < ActionView::TestCase
    test '#add accepts multiple paths' do
      menu = Menu.new(proc {})
      menu.add('Item', '1', [:post, '2'], [:put,  '3'])

      result = menu.items.first.paths.map(&:path)

      assert_equal %w[1 2 3], result
    end

    test '#add accepts multiple options' do
      menu = Menu.new(proc {})
      menu.add('Item', 'path1', 'path2', option: 'optional')

      assert_equal 'optional', menu.items.first.option
    end
  end
end
