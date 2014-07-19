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

    test '#add creates a submenu when given a block' do
      menu = Menu.new(proc {})
      menu.add 'One', '1' do |submenu|
        assert_instance_of Menu, submenu
      end
    end

    test 'can retrieve the menu #items' do
      menu = Menu.new(proc {})
      menu.add 'One', '1'
      menu.add 'Two', '2'

      titles = [menu.items[0].title, menu.items[1].title]

      assert_equal %w[One Two], titles
    end

    test 'can iterate through the items' do
      menu = Menu.new(proc {})
      menu.add 'One', '1'
      menu.add 'Two', '2'

      items = []

      menu.each do |item|
        items << item
      end

      assert %[One Two], items.map(&:title)
    end

    test '#render' do
      menu = Menu.new(proc { 'render_this' })
      assert_equal 'render_this', menu.render
    end
  end
end
