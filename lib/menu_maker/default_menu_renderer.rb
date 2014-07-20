module MenuMaker
  class DefaultMenuRenderer < MenuRenderer
    render do
      items = build_menu do |item|
        item_output = ''
        item_output += if item.has_path?(current_path)
                         '<li class="active">'
                       else
                         "<li>"
                       end

        item_output += %{<a href="#{item.path}">#{item.title}</a>}
        item_output += '</li>'
        item_output
      end

      "<ul>#{items}</ul>"
    end
  end
end
