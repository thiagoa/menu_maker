# Menu Maker

Flexible solution to build any kind of menu in any Ruby framework. Currently best integrated with Rails.
Supports recursive menus and swappable renderers for any menu depth. For instance, you can use a renderer
for the main menu, another renderer for the submenu (if needed), and so forth.

Note this gem doesn't bundle CSS or Javascripts for you. It just eases complex HTML menu creation, keeping
your code neat and clean. Actually, it can be used to create non-HTML menus; you have to supply your own renderers
for that (more below).

## Brief history

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

That will output the whole HTML in your view; It will match the current request path and output the class
'active open' as an attribute into the li tag.

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

Note the submenu is currently rendered with different style and rules.

You can recurse into any menu depth you wish, though you can't currently do that with the default renderer.

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
extends from MenuRenderer and you are using Rails, the default path is an implicit request path; you won't need to
specify it.

Then pass the renderer into a Menu instance, build your menu and call render to output the HTML:

```ruby
# You could use yield(menu). This is here to illustrate how it works.
menu = Menu.new(renderer) do |m|
  m.add 'Item', some_path
end

menu.render
```

That's it. You can also create renderers for any menu depth: just create a MenuRendererContainer
instance and pass it into the Menu instance:

```ruby
renderer = MenuRendererContainer.new do |container|
  container.add_for_next_depth(CustomMenuRenderer.new(self, request.path))
  container.add_for_next_depth(CustomSubmenuRenderer.new(self, request.path))
end

menu = Menu.new(renderer) do |m|
  m.add 'Item', some_path do |submenu|
    submenu.add 'Subitem', some_path
  end
end

menu.render
```

The first renderer passed into the container will render the main menu. The second renderer will
render the submenus, and so forth.

You can easily pack these short and simple factory methods into a custom helper, and use them for
your own needs.

## Creating custom renderers

TODO.

## Contributing

- Fork the project
- Create a feature branch
- Make your code changes with tests
- Make a Pull-Request

This project uses MIT\_LICENSE
