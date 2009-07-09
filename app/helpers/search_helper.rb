module SearchHelper
  # Searchgasm helpers
  def remote_order_by_link_display_working(options, html_options = {})
    html_options.merge!(:remote => display_working_options)
    remote_order_by_link(options, html_options)
  end

  def remote_page_links_display_working
    remote_page_links(:remote => display_working_options)
  end

  def remote_per_page_select_display_working(options)
    remote_per_page_select(options)
  end

  def observe_form_display_working(form_id, options={})
    options.merge!({:method => :get})
    observe_form(form_id, options.merge(display_working_options))
  end

  def search_page_selector(data_type="")
    render :partial => "common/search_page_selector", :locals => { :data_type => data_type }
  end

  def display_working_options
    {:before => "$('working').show()", :complete => "$('working').hide()"}
  end
end
