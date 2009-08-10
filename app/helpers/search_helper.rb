module SearchHelper
  def xls_export_link(options={})
    options.merge!(:search => options[:search])
    options.merge!(:filtrar => options[:filtrar])
    export_link :xls, options
  end

  def export_link(format, options={})
    content_tag(:span,
                link_to("Exportar #{format}",
                  :action => if options[:action] then options[:action] else action_name end,
                  :format => format,
                  :search => if options[:search] then options[:search] else nil end),
                :id => "#{format}_export")
  end

  def remote_page_links_display_working
    remote_page_links(:remote => display_working_options)
  end

  def remote_per_page_select_display_working(options)
    remote_per_page_select(options)
  end

  def search_page_selector(data_type="")
    render :partial => "common/search_page_selector", :locals => { :data_type => data_type }
  end

  def display_working_options
    {:before => "$('working').show()", :complete => "$('working').hide()"}
  end
end
