module MenuMaker
  class MenuItemTest < ActionView::TestCase
    test '#initialize accepts many paths' do
      item = Menu::MenuItem.new 'Title', 'path/1', 'path/2', 'path/3'
      assert_equal %w[path/1 path/2 path/3], item.paths.map(&:path)
    end

    test 'can access initializer options as methods' do
      item = Menu::MenuItem.new('Title', 'path', custom: 'option')
      assert_equal 'option', item.custom
    end

    test '#path returns the first path' do
      item = Menu::MenuItem.new 'Title', 'path1', 'path2', 'path3'
      assert_equal 'path1', item.path
    end

    def menu_item_for_paths_test
      Menu::MenuItem.new('One', '1').tap do |item|
        Menu.new(proc {}) do |menu2|
          menu2.add 'Two', '2', '2.1'
          menu2.add 'Three', '3' do |menu3|
            menu3.add 'Three.2', '3.2' do |menu4|
              menu4.add 'Three.2.1', '3.2.1'
            end

            menu3.add 'Three.3', '3.3'
          end

          item.submenu = menu2
        end
      end
    end

    test '#submenu_paths returns all underlying paths' do
      menu_item = menu_item_for_paths_test

      expected = ['2', '2.1', '3', '3.2', '3.2.1', '3.3']
      assert_equal expected, menu_item.submenu_paths.map(&:path)
    end

    test '#all_paths returns first level paths, plus submenu paths' do
      menu_item = menu_item_for_paths_test

      expected = ['1', '2', '2.1', '3', '3.2', '3.2.1', '3.3']
      assert_equal expected, menu_item.all_paths.map(&:path)
    end

    test "a menu item only #has_path? of its own" do
      menu = Menu.new(proc {}) do |menu1|
        menu1.add 'One', '1'
        menu1.add 'Two', '2' do |menu2|
          menu2.add 'Two.2', '2.2' do |menu3|
            menu3.add 'Two.2.1', '2.2.1'
          end

          menu2.add 'Two.3', '2.3'
          menu2.add 'Two.4', '2.4'
        end
      end

      assertions = [
        menu.items[0].has_path?('1'),
        menu.items[0].has_path?('2'),
        menu.items[0].has_path?('2.2.1')
      ]

      assert_equal [true, false, false], assertions

      assertions = [
        menu.items[1].has_path?('2'),
        menu.items[1].has_path?('2.2'),
        menu.items[1].has_path?('2.2.1'),
      ]

      assert_equal [true, true, true], assertions
    end

    test '#has_path? also matches on secondary paths of the same item' do
      item = Menu::MenuItem.new 'Item', 'main_path', [:post, 'other/path']

      assertions = [
        item.has_path?([:post, 'other/path']),
        item.has_path?(Path.new(:post, 'other/path'))
      ]

      assert_equal [true, true], assertions
    end

    test "#has_submenu? returns false when item doesn't have a submenu" do
      item = Menu::MenuItem.new 'One', 'level/1'

      refute item.has_submenu?
    end

    test "#has_submenu? returns true when item has a submenu" do
      item = Menu::MenuItem.new 'One', 'level/1'
      item.submenu = Menu.new(proc {})

      assert item.has_submenu?
    end
  end
end
