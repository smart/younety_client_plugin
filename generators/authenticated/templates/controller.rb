# This controller handles the login/logout function of the site.  
class <%= controller_class_name %>Controller < ApplicationController
  # Be sure to include YouserSystem in Application Controller instead
  include YouserSystem
  # If you want "remember me" functionality, add this before_filter to Application Controller
  before_filter :login_from_cookie

  # render new.rhtml
  def new
  	@context = 'login'
  end
  
  #this is the create function for session
  def create
    youser_authenticate
    return false
  end

  def destroy
    #self.current_<%= file_name %>.forget_me if logged_in?
    @current_<%= file_name %>.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_to("/")
  end
  
end
