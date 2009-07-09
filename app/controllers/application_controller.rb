# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  helper_method :current_user_session, :current_user, :logged_in?#, :home_url_for_user
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password, :password_confirmation

  private
    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end

    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.user
    end

    def require_user
      unless current_user
        store_location
        redirect_to new_user_session_url
        return false
      end
    end

    def require_no_user
      if current_user
        store_location
        flash[:notice] = "You are already logged in"
        redirect_to account_url
        return false
      end
    end

    def store_location  
      session[:return_to] = request.request_uri
    end

    def redirect_back_or_default(default) 
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end

    def logged_in?
      current_user
    end

=begin
    def get_namespace
      my_class_name = self.class.name
      if my_class_name.index("::").nil? then
        @module_name = nil
      else
        @module_name = my_class_name.split("::").first.underscore
      end
    end
=end

=begin
    def home_url_for_user(user)
      return resumen_vigiladores_url if user.is_a? ContabilidadUser
      return recursos_humanos_vigiladores_url if user.is_a? RecursosHumanosUser
      return logistica_vigiladores_url if user.is_a? LogisticaUser
      return sueldos_vigiladores_url if user.is_a? SueldosUser
      return resumen_vigiladores_url if user.is_a? AdminUser
    end
=end

    def deny_access
      flash[:notice] = "You shall not pass!"
#      redirect_to home_url_for_user(current_user)
      redirect_to root_url
      return false
    end

    def string_to_class(param)
      begin
        return if param.blank?
        constant = param.constantize
        return constant if constant.is_a? Class
      rescue NameError
        #most likely because the string is not a constant (like the string "a + 1"
      end
    end
end
