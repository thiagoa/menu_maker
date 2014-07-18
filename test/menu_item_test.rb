module MenuMaker
  class MenuItemTest < ActionView::TestCase
    test 'hash options can be accessed as methods on MenuItem' do
      item = Menu::MenuItem.new 'My title', 'my/path', from_hash: 'option'
      assert_equal 'option', item.from_hash
    end

    test 'path returns the first path from the menu item' do
      item = Menu::MenuItem.new 'My title', 'my/path'
      assert_equal 'my/path', item.path
    end

    test 'accepts many paths' do
      item = Menu::MenuItem.new 'My title', 'path/1', 'path/2', 'path/3'
      assert_equal ['path/1', 'path/2', 'path/3'], item.paths.map(&:path)
    end

    test 'submenu_paths returns submenu paths recursively' do
      item = Menu::MenuItem.new 'Level 1', 'level/1'

      menu2 = Menu.new(->(){})
      menu2.add 'Level 2', 'level/2' do |menu3|
        menu3.add 'Level 3', 'level/3'
        menu3.add 'Level 4', 'level/4' do |menu4|
          menu4.add 'Level 6', 'level/6'
        end
        menu3.add 'Level 5', 'level/5'
      end
      menu2.add 'Level 2/1', 'level/2/1'
      menu2.add 'Level 2/2', 'level/2/2'

      item.submenu = menu2

      expected = %w[level/2 level/2/1 level/2/2 level/3 level/4 level/5 level/6]

      assert_equal expected, item.submenu_paths.map(&:path).sort
    end

    test 'all_paths returns submenu paths + current menu path' do
      item = Menu::MenuItem.new 'Level 1', 'level/1'

      menu2 = Menu.new(->(){})
      menu2.add 'Level 2', 'level/2' do |menu3|
        menu3.add 'Level 3', 'level/3'
        menu3.add 'Level 4', 'level/4' do |menu4|
          menu4.add 'Level 6', 'level/6'
        end
        menu3.add 'Level 5', 'level/5'
      end

      item.submenu = menu2

      expected = %w[level/1 level/2 level/3 level/4 level/5 level/6]

      assert_equal expected, item.all_paths.map(&:path).sort
    end

    test 'has_path? also checks for submenus' do
      item = Menu::MenuItem.new 'Level 1', 'level/1'

      menu2 = Menu.new(->(){})
      menu2.add 'Level 2', 'level/2' do |menu3|
        menu3.add 'Level 3', 'level/3'
        menu3.add 'Level 4', 'level/4' do |menu4|
          menu4.add 'Level 6', 'level/6'
        end
        menu3.add 'Level 5', 'level/5'
      end

      item.submenu = menu2

      assert item.has_path?('level/4')
      assert item.has_path?('level/1')
      refute item.has_path?('level/8')
    end

    test 'Menu#add accepts multiple paths and options' do
      menu = Menu.new proc {}
      menu.add('Item', 'path/1', [:post, 'path/2'], [:put, 'path/3'], option: 'optional')

      result = menu.items.first.paths.map(&:path)

      expected = %w[path/1 path/2 path/3]

      assert_equal expected, result
      assert_equal 'optional', menu.items.first.option
    end

    test 'has_path? matches on other restful paths' do
      item = Menu::MenuItem.new 'Item', 'main_path', [:post, 'other/path']

      assert item.has_path? [:post, 'other/path']
      assert item.has_path? Path.new(:post, 'other/path')
    end

    test "has_submenu? when returns false" do
      item = Menu::MenuItem.new 'Level 1', 'level/1'
      refute item.has_submenu?
    end

    test "has_submenu? when returns true" do
      item = Menu::MenuItem.new 'Level 1', 'level/1'
      item.submenu = Menu.new(->(){})
      assert item.has_submenu?
    end
  end
end
