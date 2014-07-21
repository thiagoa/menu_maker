# Menu Maker

[![Gem Version](https://badge.fury.io/rb/menu_maker.png)](http://badge.fury.io/rb/menu_maker)
[![Code Climate](https://codeclimate.com/github/thiagoa/menu_maker.png)](https://codeclimate.com/github/thiagoa/menu_maker)
[![Travis CI](https://travis-ci.org/thiagoa/menu_maker.svg)](https://travis-ci.org/thiagoa/menu_maker)
[![Test Coverage](https://codeclimate.com/github/thiagoa/menu_maker/coverage.png)](https://codeclimate.com/github/thiagoa/menu_maker)

Flexible solution to build HTML menus in any Ruby framework.

- Declare your menus with a beaultiful high level syntax
- Suitable for simple or complex HTML menus
- The menu building logic is kept separate from the rendering logic, that means you can provide your own renderers
- Supports any depth of submenus
- Supports distinct renderers for any number of submenus
- Supports restful paths to build the menu state
- Comes with a Rails helper
- Flexible OO; you can pass menu objects around and build'em the way you want.

Note that this gem doesn't bundle CSS or javascripts for you, mostly because every menu out there is different; you must provide
you own assets, or build another gem to pack your setup.

This gem makes it easy to build complex HTML menus, keeping your code neat and clean. It also provides tools to work with menus.
Actually, it can be used to create non-HTML menus, but you have to supply your own renderers for that.

## But why?

This gem was born when I needed to build a complex menu, and couldn't figure out anything suited for the task.
So I began like lots of Rails developers do: I quickly crafted a very big and messy procedural helper method,
that was very hard to change, test and maintain. The monster was born and I wasn't happy at all, so I refactored for
fun. The code is small for the flexibility it provides, and much easier to work with.

## Compatibility

- Ruby >= 2.0
- Any Ruby application

## Installation

Add it to your Gemfile:

```ruby
gem 'menu_maker'
```

Run the following command to install it:

```ruby
bundle install
```

## Usage

### With Rails

The default renderer creates a simple menu, with unordered list markup. The Rails helper is aware
of the current URL, and therefore puts an "active" class in the *li* which matches the current URL.
Here's what the generated markup looks like **with the default renderer**:

```html
<ul>
  <li>
    <a href="/first/item">First item</a>
  </li>
  <li class="active">
    <a href="/second/item">Second item</a>
  </li>
  <li>
    <a href="/third/item">Third item</a>
    <ul>
      <li>
        <a href="/first/submenu/item">First submenu item</a>
      </li>
    </ul>
  </li>
</ul>
```

To create a menu like that, use the following code on your view:

```erb
<%= menu_maker do |menu| %>
  <% menu.add 'First item',  first_item_path %>
  <% menu.add 'Second item', second_item_path %>
  <% menu.add 'Third item', third_item_path do |submenu| %>
    <%= submenu.add 'First submenu item', first_item_submenu_path %>
  <% end %>
<% end %>
```

The Rails helper builds and outputs the HTML menu all at once, which is mostly likely what you'll want.

You can also provide more than one path for a menu item - useful when it needs to be active in the context
of other paths or request methods:

```erb
<%= menu_maker do |menu| %>
  <% menu.add 'Create user', new_user_path, [:post, users_path] %>
<% end %>
```

For instance, the *Create User* menu item needs to be active whether with a **GET new** or a **POST create**
restful action; that's because if the saving fails, the create action will render back the "new" template.
Note that the very first path will be used in the HTML anchor; *MenuMaker* will assume the request
method is GET when not specified.

### Manual usage and options

First you need to instantiate a renderer:

```ruby
renderer = MyRenderer.new(self)
```

The first parameter is optional, and provides some helpers that the renderer might use. Inside a Rails helper, for example,
the *self* object points to all other helpers. The second parameter is the current URL, also optional - the renderer will use
it to build the menu state. If you are using Rails, the renderer will find the current URL using the helper context.

Second, create a *Menu* instance with the renderer as the first argument, and don't forget to call the *render* method to
output the HTML:

```ruby
menu_maker = MenuMaker::Menu.new(renderer) do |menu|
  menu.add 'Item', some_path
end

menu_maker.render
```

#### Paths

You can supply any number of paths for a menu item:

```ruby
MenuMaker::Menu.new(renderer) do |menu|
  menu.add 'Create user', new_user_path, [:post, users_path]
end
```

*MenuMaker* will match all the paths you provide, to build the state of a particular menu item. The first path shall be the
main one, used in the HTML anchor. When you don't specify the request method for a path, *MenuMaker* will assume the GET method.

There is also a *Path* conversion protocol:

```ruby
MenuMaker::Menu.new(renderer) do |menu|
  menu.add 'Create user', Path(new_user_path), Path(:post, users_path)
end
```

Path inputs are maleable; whatever you provide, *MenuMaker* will do its best to understand. Actually, even if you don't use
the conversion method explicitly, paths will be handled behind the curtains.

#### Custom options

You can also provide custom options for each menu item:

```ruby
MenuMaker::Menu.new(renderer) do |menu|
  menu.add 'First link', [:get, dashboard_path], icon: 'fa fa-dashboard'
end
```

In the last example, the *icon* option wil be available for the renderer to do whatever it wants with it.

### Creating renderers

#### Class renderers

If your logic is reasonably complex, your custom renderer should be a subclass of *MenuRenderer*. This approach
is also recommended if you want to use built-in helpers.

You *must* call the *render* class method in your subclass body:

```ruby
class MyRenderer < MenuRenderer
  render do
    # Place your core rendering logic here
  end
end
```

The *MenuRenderer* class has a *build\_menu* method, which helps you render each menu item:

```ruby
class MyRenderer < MenuRenderer
  render do
    items_output = build_menu do |item|
      "<li><a href="#{item.path}">#{item.title}</a></li>"
    end

    "<ul>#{items_output}</ul>"
  end
end
```

You can query your item, for example, to determine if it needs custom CSS classes:

```ruby
class MyRenderer < MenuRenderer
  render do
    items_output = build_menu do |item, css_class|
      css_class << 'dropdown' if item.has_submenu?
      css_class << 'active'   if item.has_path?(current_path)

      klass = if css_class.any?
        %{ class="#{css_class.join(' ')}"}
      else
        ''
      end

      "<li#{klass}><a href="#{item.path}">#{item.title}</a></li>"
    end

    "<ul>#{items_output}</ul>"
  end
end
```

*MenuRenderer* has a *build\_html* helper method, which automatically calls *html\_safe* for you (if you
are using Rails). Remember to use it in each HTML part (except for *build\_menu*, which implicitly uses it):

```ruby
class MyRenderer < MenuRenderer
  render do
    items_output = build_menu do |item, css_class|
      title = render_title(item)
      # item rendering logic
    end

    "<ul>#{items_output}</ul>"
  end

  private
  
  def render_title(item)
    build_html do
      # title rendering logic
    end
  end
end
```

If you are using Rails, you can use regular helpers to clean up your code:

```ruby
class MyRenderer < MenuRenderer
  render do
    items_output = build_menu do |item, css_classes|
      helpers.content_tag :li do
        helpers.link_to item.title, item.path
      end
    end

    # You can also use the h method, instead of the verbose helpers
    helpers.content_tag :ul { items_output }
  end
end
```

Here is a short example of a Rails helper:

```ruby
module MyHelper
  def my_menu
    renderer = MyRenderer.new(self)

    menu = Menu.new(renderer) do |m|
      # Build your menu here
    end

    menu.render
  end
end
```

#### Proc renderers

You can use any object which responds to *call* as a renderer. We will use raw HTML to illustrate
these examples, so you can see how a proc renderer works without any conceptual overhead;
You can use HTML helpers to make things cleaner.

Proc renderers are recommended when your logic is short and simple; for complex logic we recommend
extending the *MenuRenderer* class, which also provides useful helpers to assist you, so you don't
have to worry about nasty details like calling *html\_safe* on you strings (*html\_safe* hell),
and other related concerns.

```ruby
renderer = proc do |menu|
  items = menu.inject('') do |html, item|
    %{#{html} <li><a href="#{item.path}">#{item}</a></li>}
  end

  "<ul>#{items}</ul>"
end

menu_maker = MenuMaker::Menu.new(renderer) do |menu|
  menu.add 'Item', '/some/path'
end

# outputs <ul><li><a href="/some/path">Item</li></ul>
menu_maker.render
```

If you want to render submenus, you must explicitly call *render\_submenu* on the menu item:

```ruby
renderer = proc do |menu|
  items = menu.inject('') do |html, item|
    %{#{html} <li><a href="#{item.path}">#{item}</a>#{item.render_submenu}</li>}
  end

  "<ul>#{items}</ul>"
end

menu_maker = MenuMaker::Menu.new(renderer) do |menu|
  menu.add 'Item', '/some/path' do |submenu|
    submenu.add 'Subitem', '/some/path/new'
  end
end

menu_maker.render

```

It becomes much more useful when you create a renderer like this:

```ruby
renderer = proc do |menu|
  items = menu.inject('') do |html, item|
    # has_path? Also checks for submenu paths
    li_class = ' class="active"' if item_has_path?(request.path)
    link     = %{<a href="#{item.path}">#{item}</a>}

    "#{html} <li#{li_class || ''}>#{link} #{item.render_submenu}</li>"
  end

  "<ul>#{items}</ul>"
end
```

We are adding an *active* class to the *li*, if the request path matches. You can also check if the item has
a submenu and add a *dropdown* class to the *li*, like so:

```ruby
renderer = proc do |menu|
  items = menu.inject('') do |html, item|
    li_class = ' class="dropdown"' if item.has_submenu?
    link     = %{<a href="#{item.path}">#{item}</a>}

    "#{html} <li#{li_class || ''}>#{link} #{item.render_submenu}</li>"
  end

  "<ul>#{items}</ul>"
end
```

#### Rendering submenus

You can also create renderers for any submenu level: use a *MenuRendererCollection*
object to hold your renderers, and pass the collection into the *Menu* instance:

```ruby
CustomMenuRenderer < MenuRenderer
  render do
    # menu rendering logic
  end
end

CustomSubmenuRenderer < MenuRenderer
  render do
    # submenu rendering logic
  end
end

renderers = MenuRendererCollection.new do |collection|
  collection.add CustomMenuRenderer.new(self)
  collection.add CustomSubmenuRenderer.new(self)
end

final_menu = Menu.new(renderers) do |menu|
  menu.add 'Item 1', 'my/path'
  menu.add 'Item 2', 'my/path' do |submenu|
    submenu.add 'Item 2.1', 'my/path'
  end
end

final_menu.render
```

Here the first renderer of the collection will render the main menu; the second renderer will
render the submenu.

You can easily pack your setup with custom helpers.

## Contributing

- Fork the project
- Create a feature branch
- Make your code changes with tests
- Make a Pull-Request

This project uses MIT\_LICENSE

[GV img]: https://d25lcipzij17d.cloudfront.net/badge.svg?id=rb&type=5&v=0.0.4
[CC img]: https://codeclimate.com/github/thiagoa/menu_maker.png

