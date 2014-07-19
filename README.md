# Menu Maker

[![Gem Version](https://badge.fury.io/rb/menu_maker.png)](http://badge.fury.io/rb/menu_maker)
[![Code Climate](https://codeclimate.com/github/thiagoa/menu_maker.png)](https://codeclimate.com/github/thiagoa/menu_maker)
[![Travis CI](https://travis-ci.org/thiagoa/menu_maker.svg)](https://travis-ci.org/thiagoa/menu_maker)
[![Test Coverage](https://codeclimate.com/github/thiagoa/menu_maker/coverage.png)](https://codeclimate.com/github/thiagoa/menu_maker)

Flexible solution to build any kind of menu in any Ruby framework. Currently best integrated with Rails.
Supports recursive menus and swappable renderers for any menu depth. For instance, you can use a renderer
for the main menu, another renderer for the submenu (if needed), and so forth.

Note this gem doesn't bundle CSS or Javascripts for you. It just eases complex HTML menu creation, keeping
your code neat and clean. Actually, it can be used to create non-HTML menus; you have to supply your own renderers
for that (more below).

## But why?

This gem was born when I needed to build a complex menu, and couldn't figure out anything suited for the task.
So I began like lots of Rails developers do: I quickly crafted a big and messy procedural helper method,
that was very hard to change and maintain. It couldn't be used for anything else, everything was hardcoded in
stone, including very specific concepts. The monster was born and I wasn't happy at all, so I refactored for
fun and made a generic solution that works with anything. The code is small for the flexibility it provides,
and much easier to change and maintain. Renderers are short and easy to build.

## Installation

If you are using Rails, it is compatible with the 4.0 series. Add it to your Gemfile:

```ruby
gem 'menu_maker'
```

Run the following command to install it:

```ruby
bundle install
```

## Usage

## With Rails

The default menu renderer creates a menu like this, with full funcionality: http://startbootstrap.com/templates/sb-admin

This gem was extracted from a real project with no modifications as of now; this is the very first version,
so a simpler default renderer is on the way, which shall be suited for most people.

To create a menu like that, use the following code on your view:

```erb
<%= menu_maker do |menu| %>
  <% menu.add 'First link',  some_path %>
  <% menu.add 'Second link', some_path %>
<% end %>
```

That will output the whole HTML in your view; It will match the current request path, and output the class
'active open' as an attribute into the li tag which contains the active link.

It's also possible to supply more than one path for a single menu item, useful when an item needs to be active
in the context of other paths or request methods. For instance, a *Create User* menu item needs to be active whether
using the **GET new** or **POST create** restful actions; that's because if the save fails, the create action will
render back the "new" template. Note that the first path is the main one, and will be used in the anchor with the default
renderer; this is also the recomended behavior for custom renderers. Currently, with the default renderer, the first
path needs to be **GET**, otherwise it will be interpreted as **GET** anyway.

```erb
<%= menu_maker do |menu| %>
  <% menu.add 'Create user', new_user_path, [:post, users_path] %>
<% end %>
```

There is also a Path conversion method if you prefer:

```erb
<%= menu_maker do |menu| %>
  <% menu.add 'Create user', Path(new_user_path), Path(:post, users_path) %>
<% end %>
```

The path inputs are maleable, and MenuMaker will do its best to sensibly convert
a path internally.

You can also output submenus:

```erb
<%= menu_maker do |menu| %>
  <% menu.add 'First link',  some_path do |submenu| %>
    <% submenu.add 'First sublink',  some_path %>
    <% submenu.add 'Second sublink', some_path %>
  <% end %>

  <% menu.add 'Second link', some_path %>
<% end %>
```

Note the submenu is currently rendered (by default) with different style and rules.

You can recurse into any menu depth you wish, though you can't currently do that (by default)
with the default renderer, which only renders two depths.

You can also provide a custom option hash for each menu item (it will be available inside your renderer):

```erb
<%= menu_maker do |menu| %>
  <% menu.add 'First link', some_path, icon: 'fa fa-dashboard' %>
<% end %>
```

## Manual usage

First you need to instantiate a renderer:

```ruby
renderer = MyRenderer.new(self, request.path)
```

The first parameter is a context for the renderer to use. If you use it with Rails and from a helper module,
for example, the *self* object will provide access to all the helpers. The second parameter is the current
request path, which you can use inside your renderer to mark a menu item as active, for example. If your renderer
extends from *MenuRenderer* and you are using Rails, the default path is an implicit request path; you won't need to
specify it.

Then pass the renderer into a Menu instance, build your menu and call render to output the HTML:

```ruby
# You could use yield(menu). This is here to illustrate how it works.
menu_maker = MenuMaker::Menu.new(renderer) do |menu|
  menu.add 'Item', some_path
end

menu_maker.render
```

That's it. You can also create renderers for any menu depth: just create a MenuRendererCollection
instance and pass it into the Menu instance:

```ruby
renderer = MenuMaker::MenuRendererCollection.new do |collection|
  collection.add(CustomMenuRenderer.new(self, request.path))
  collection.add(CustomSubmenuRenderer.new(self, request.path))
end

menu_maker = MenuMaker::Menu.new(renderer) do |menu|
  menu.add 'Item', some_path do |submenu|
    submenu.add 'Subitem', some_path
  end
end

menu_maker.render
```

The first renderer of the collection will render the main menu. The second renderer will
render the submenus, and so forth.

You can easily pack these short and simple factory methods into a custom helper, and use them for
your own needs.

## Creating custom renderers

### Proc renderers

You can use any object which responds to *call* as a renderer. We will use raw HTML to illustrate
these examples, so you can clearly see how a proc renderer works, without any conceptual overhead;
You can use Rails HTML helpers (or any web framework) to make things cleaner.

Proc renderers are recommended when your logic is short and simple; for complex logic we recommend
extending the *MenuRenderer* class, which also provides useful helpers to assist you, so you don't
have to worry about nasty details like calling *html\_safe* on you strings (*html\_safe* hell),
and related concerns.

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

# outputs
#
# <ul>
#   <li>
#     <a href="/some/path">Item</a>
#     <ul>
#       <li>
#         <a href="/some/path/new">Subitem</a>
#       </li>
#     </ul>
#   </li>
# </ul>
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

### Class renderers

TODO.

## Contributing

- Fork the project
- Create a feature branch
- Make your code changes with tests
- Make a Pull-Request

This project uses MIT\_LICENSE

[GV img]: https://d25lcipzij17d.cloudfront.net/badge.svg?id=rb&type=5&v=0.0.4
[CC img]: https://codeclimate.com/github/thiagoa/menu_maker.png

