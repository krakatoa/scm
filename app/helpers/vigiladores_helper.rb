module VigiladoresHelper
  def cancel_link
    link_to_function(image_tag("cancel.png"), nil, :class => "link-cancel") do |page|
      page[:new_vigilador].remove
      page['link-new'].show
      page[".link-edit"].show
    end
  end

  def cancel_alta_link(id)
    link_to_function(image_tag("cancel.png"), nil, :class => "link-cancel-alta") do |page|
      page["alta_vigilador_#{id}"].replace_html "<td id=\"alta_vigilador_#{id}\" \/>"
    end
  end
end