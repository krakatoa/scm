# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  # TODO manejar los notices, flashes y errores con helpers
end

module ActionView
  module Helpers
    class FormBuilder
      def input_text(method, options = {})
        options[:label] ||= method.to_s.titleize
        @template.render :partial => 'common/input_text', :locals => { :object => @object_name, :method => method, :options => options }
      end

      def input_password(method, options = {})
        options[:label] ||= method.to_s.titleize
        @template.render :partial => 'common/input_password', :locals => { :object => @object_name, :method => method, :options => options }
      end
    end
  end
end
