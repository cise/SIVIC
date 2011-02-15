# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  include ActionController::Sessions

  # render new.rhtml
  def new
    store_location(params[:redirect_to]) if params[:redirect_to].present? &&
      # Prevent redirecting to other host
      params[:redirect_to] =~ /^\//

    authentication_methods_chain(:new)
  end

  def create
    if authentication_methods_chain(:create)
      respond_to do |format|
        format.html {
          redirect_back_or_default(after_create_path)
        }
        format.js
      end unless performed?
    else
      respond_to do |format|
        format.html {
          flash[:error] ||= t(:invalid_credentials)
          render(:action => "new")
        }
        format.js
      end unless performed?
    end
  end

  def destroy
    authentication_methods_chain(:destroy)

    reset_session

    return if performed?

    flash[:notice] = t(:logged_out)
    redirect_back_or_default(after_destroy_path)
  end

  private

  def after_create_path
    '/'
  end

  def after_destroy_path
    '/'
  end
end
