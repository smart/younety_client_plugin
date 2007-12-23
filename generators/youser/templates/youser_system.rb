module YouserSystem
  require 'authenticators/open_id_helper'
  include OpenIdHelper
  require 'authenticators/facebook_helper'
  include FacebookHelper
  require 'authenticators/local_user_helper'
  include LocalUserHelper
  
  protected
    # Returns true or false if the <%= file_name %> is logged in.
    # Preloads @current_<%= file_name %> with the <%= file_name %> model if they're logged in.
    def logged_in?
      current_<%= file_name %> != :false
    end
    
    # Accesses the current <%= file_name %> from the session.
    def current_<%= file_name %>
      @current_<%= file_name %> ||= (session[:<%= file_name %>] && <%= class_name %>.find_by_id(session[:<%= file_name %>])) || :false
    end
    
    # Store the given <%= file_name %> in the session.
    def current_<%= file_name %>=(new_<%= file_name %>)
      session[:<%= file_name %>] = (new_<%= file_name %>.nil? || new_<%= file_name %>.is_a?(Symbol)) ? nil : new_<%= file_name %>.id
      @current_<%= file_name %> = new_<%= file_name %>
    end
    
    # Check if the <%= file_name %> is authorized.
    #
    # Override this method in your controllers if you want to restrict access
    # to only a few actions or if you want to check if the <%= file_name %>
    # has the correct rights.
    #
    # Example:
    #
    #  # only allow nonbobs
    #  def authorize?
    #    current_<%= file_name %>.login != "bob"
    #  end
    def authorized?
      true
    end

    # Filter method to enforce a login requirement.
    #
    # To require logins for all actions, use this in your controllers:
    #
    #   before_filter :login_required
    #
    # To require logins for specific actions, use this in your controllers:
    #
    #   before_filter :login_required, :only => [ :edit, :update ]
    #
    # To skip this in a subclassed controller:
    #
    #   skip_before_filter :login_required
    #
    def login_required
      <%= file_name %>name, passwd = get_auth_data
      p fbsession
      self.current_<%= file_name %> ||= LocalUser.authenticate(<%= file_name %>name, passwd) || :false if <%= file_name %>name && passwd
      if logged_in? && authorized?  
        current_<%= file_name %>.complete? ? true : unfinished_registration
      else 
        access_denied
      end
    end
    
    # Redirect as appropriate when an access request fails.
    #
    # The default action is to redirect to the login screen.
    #
    # Override this method in your controllers if you want to have special
    # behavior in case the <%= file_name %> is not authorized
    # to access the requested action.  For example, a popup window might
    # simply close itself.
    def access_denied
      respond_to do |accepts|
        accepts.html do
          store_location
          redirect_to :controller => 'sessions', :action => 'new'
        end
        accepts.xml do
          headers["Status"]           = "Unauthorized"
          headers["WWW-Authenticate"] = %(Basic realm="Web Password")
          render :text => "Could't authenticate you", :status => '401 Unauthorized'
        end
      end
      false
    end
    
    
    # Redirect as appropriate when a <%= file_name %> registration is not complete
    #
    # The default action is to redirect to the register screen
    #
    # Override this method in your controllers if you want to have special
    # behavior in case the <%= file_name %> is not complete
    # to access the requested action.  For example, a popup window might
    # simply close itself.
    def unfinished_registration
      params = {:<%= file_name %> => current_<%= file_name %>.attributes}
      respond_to do |accepts|
        accepts.html do
          #store_location
          redirect_to :controller => '<%= model_controller_file_name %>', :action => 'finish_registration'
        end
        accepts.xml do
          headers["Status"]           = "Unauthorized"
          headers["WWW-Authenticate"] = %(Basic realm="Web Password")
          render :text => "You do not have a complete registration please visit the site to complete.", :status => '401 Unauthorized'
        end
      end
      false
    end  
    
    # determines while authenticator to load 
    #
    # returns false is none is detected
    def determine_authenticator
      return "OpenId" if using_open_id?
      return "Facebook" if using_facebook?
      return "LocalUser" if using_local_user?
      return false
    end
    
    
    #if one of the authenticatos is successful this is called
    
     def successful_login
      if params[:remember_me] == "1"
        self.current_<%= file_name %>.remember_me
        cookies[:auth_token] = { :value => self.current_<%= file_name %>.remember_token , :expires => self.current_<%= file_name %>.remember_token_expires_at }
      end
      if !current_<%= file_name %>.complete?
        unfinished_registration
      else
        redirect_back_or_default('/')
        flash[:notice] = "Logged in successfully"
      end
    end
    
    #if the authenticator failes this is called
    
    def failed_login(message)
      flash.now[:error] = message
      render :action => 'new'
    end  
    
    # Store the URI of the current request in the session.
    #
    # We can return to this location by calling #redirect_back_or_default.
    def store_location
      session[:return_to] = request.request_uri
    end
    
    # Redirect to the URI stored by the most recent store_location call or
    # to the passed default.
    def redirect_back_or_default(default)
      session[:return_to] ? redirect_to_url(session[:return_to]) : redirect_to(default)
      session[:return_to] = nil
    end
    
    # Inclusion hook to make #current_<%= file_name %> and #logged_in?
    # available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_<%= file_name %>, :logged_in?
    end

    # When called with before_filter :login_from_cookie will check for an :auth_token
    # cookie and log the <%= file_name %> back in if apropriate
    def login_from_cookie
      return unless cookies[:auth_token] && !logged_in?
      <%= file_name %> = <%= class_name %>.find_by_remember_token(cookies[:auth_token])
      if <%= file_name %> && <%= file_name %>.remember_token?
        <%= file_name %>.remember_me
        self.current_<%= file_name %> = <%= file_name %>
        cookies[:auth_token] = { :value => self.current_<%= file_name %>.remember_token , :expires => self.current_<%= file_name %>.remember_token_expires_at }
        flash[:notice] = "Logged in successfully"
      end
    end

  private
    @@http_auth_headers = %w(X-HTTP_AUTHORIZATION HTTP_AUTHORIZATION Authorization)
    # gets BASIC auth info
    def get_auth_data
      auth_key  = @@http_auth_headers.detect { |h| request.env.has_key?(h) }
      auth_data = request.env[auth_key].to_s.split unless auth_key.blank?
      return auth_data && auth_data[0] == 'Basic' ? Base64.decode64(auth_data[1]).split(':')[0..1] : [nil, nil] 
    end
end
