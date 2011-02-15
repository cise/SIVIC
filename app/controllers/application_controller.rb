# Copyright 2008-2010 Universidad Politécnica de Madrid and Agora Systems S.A.
#
# This file is part of VCC (Virtual Conference Center).
#
# VCC is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# VCC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with VCC.  If not, see <http://www.gnu.org/licenses/>.

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base  
  # Be sure to include AuthenticationSystem in Application Controller instead
  include SimpleCaptcha::ControllerHelpers 
  include LocaleControllerModule
 
#  alias_method :rescue_action_locally, :rescue_action_in_public
 
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '29d7fe875960cb1f9357db1445e2b063'

  # Don't log passwords
  filter_parameter_logging :password, :password_confirmation
  
  # This method calls one from the plugin, to get the Space from params or session
  def space
    @space ||= current_container(:type => :space, :path_ancestors => true)
  end

  # This method is the same as space, but raises error if no Space is found
  def space!
    space || raise(ActiveRecord::RecordNotFound)
  end

   before_filter :update_activity_time
	
	def session_expiry
		reset_session
		flash[:error] = t('session.error.expire')
		redirect_to :controller => 'frontpage', :action => 'index'
	end

#	def update_activity_time
#		session[:expires_at] = 30.minutes.from_now
#	end

	def update_activity_time
         if logged_in?
		from_now = 15.minutes.from_now
		if session[:expires_at].blank?
			session[:expires_at] = from_now
		else
			@time_left = (session[:expires_at].utc - Time.now.utc).to_i
			unless @time_left > 0
			session[:expires_at] = from_now
			session_expiry
		end
         end
	end
end

  helper_method :space, :space!

  before_filter :not_activated_warning
  def not_activated_warning
    if authenticated? && ! current_agent.active?
      #if the account is going to be activated we only show the activaton flash not this one
      unless params[:controller] == "users" && params[:action]=="activate"
        flash[:notice] = t('user.not_activated') + 
                         "<br />Su cuenta debe estar activada para hacer reservaciones de salas." +
                         "<br />Su solicitud para unirse a su institución está siendo procesada."
      end
    end
  end
  
  before_filter :set_time_zone
  def set_time_zone
    if current_user && current_user.is_a?(User) && current_user.timezone
      Time.zone = current_user.timezone
    else
      Time.zone = 'UTC'
    end
    if current_user && current_user.is_a?(User) && authenticated? && current_agent.active? && !current_user.superuser?
#      logger.error "space=#{current_user.main_space} Timezone=#{Time.zone.name} current_user.timezone=#{current_user.timezone} country_timezone=#{Country.find_by_code(current_user.main_space.country).timezone}"
      if current_user.main_space && !Country.find_by_code(current_user.main_space.country).nil? && Time.zone.name != Country.find_by_code(current_user.main_space.country).timezone
        flash.now[:notice] = "Su zona horaria es diferente a la de su institución principal. Para cambiarla haga <a href=\"#{edit_user_path(current_user)}\">click aquí</a>"
      end
    end
  end

  # Locale as param
  before_filter :set_vcc_locale

  def render_optional_error_file(status_code)
    if status_code == 403
      render_403
    elsif status_code == 404
      render_404
    elsif status_code == 500
      render_500
    else
      super
    end
  end
  
  def render_403
    respond_to do |type| 
      type.html { render :template => "errors/error_403", :layout => 'application', :status => 403 } 
      type.all  { render :nothing => true, :status => 403 } 
    end
    true
  end

  def render_404
    respond_to do |type| 
      type.html { render :template => "errors/error_404", :layout => 'application', :status => 404 } 
      type.all  { render :nothing => true, :status => 404 } 
    end
    true
  end
  
  def render_500
    respond_to do |type| 
      type.html { render :template => "errors/error_500", :layout => 'application', :status => 500 } 
      type.all  { render :nothing => true, :status => 500 } 
    end
    true
  end
 
  private
  
  def accept_language_header_locale
    request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first.to_sym if request.env['HTTP_ACCEPT_LANGUAGE'].present? 
  end 
    
end
