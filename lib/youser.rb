=begin
module Youser
    require 'authenticators/open_id_authenticator'
    include Younety::Youser::Authenticators::OpenIdAuthenticator
    require 'authenticators/facebook_authenticator'
    include Younety::Youser::Authenticators::FacebookAuthenticator
    require 'authenticators/local_user_authenticator'
    include Younety::Youser::Authenticators::LocalUserAuthenticator
  
    #require 'youser/youser_authenticator'
    #include Younety::Youser::YouserAuthenticator
    #require 'youser/youser_authenticators/local_user'
    #require 'youser/youser_authenticators/facebook_youser'
    #require 'youser/youser_authenticators/open_id_youser'
    #include Younety::Youser::LocalUser
  
    protected
      # Returns true or false if the account is logged in.
      # Preloads @current_account with the account model if they're logged in.
      def logged_in?
        current_account != :false
      end
    
      # Accesses the current account from the session.
      def current_account
        @current_account ||= (session[:account] && Account.find_by_id(session[:account])) || :false
      end
    
      # Store the given account in the session.
      def current_account=(new_account)
        p "SETTING ACCOount INFO"
        session[:account] = (new_account.nil? || new_account.is_a?(Symbol)) ? nil : new_account.id
        @current_account = new_account
      end

      # Check if the account is authorized.
      #
      # Override this method in your controllers if you want to restrict access
      # to only a few actions or if you want to check if the account
      # has the correct rights.
      #
      # Example:
      #
      #  # only allow nonbobs
      #  def authorize?
      #    current_account.login != "bob"
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
        accountname, passwd = get_auth_data
        self.current_account ||= local_user_authentication || :false if accountname && passwd
        if logged_in? && authorized?  
          current_account.complete? ? true : unfinished_registration
        else 
          access_denied
        end
      end
    
      # Redirect as appropriate when an access request fails.
      #
      # The default action is to redirect to the login screen.
      #
      # Override this method in your controllers if you want to have special
      # behavior in case the account is not authorized
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
    
    
      # Redirect as appropriate when a account registration is not complete
      #
      # The default action is to redirect to the register screen
      #
      # Override this method in your controllers if you want to have special
      # behavior in case the account is not complete
      # to access the requested action.  For example, a popup window might
      # simply close itself.
      def unfinished_registration
        params = {:account => current_account.attributes}
        respond_to do |accepts|
          accepts.html do
            #store_location
            redirect_to :controller => 'accounts', :action => 'finish_registration'
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
    
      def youser_authenticate
        case determine_authenticator

            when "OpenId"
            open_id_authentication


          when "Facebook"
            facebook_authentication


          when "LocalUser"
            local_user_authentication

          else
          return false
        end
      end
    
    
      #if one of the authenticatos is successful this is called
    
       def successful_login
        unless current_account.complete?
          unfinished_registration
        else
          #redirect_to("/") and return false
          redirect_back_or_default('/')
          flash[:notice] = "Logged in successfully"
        end
      end
    
      #if the authenticator failes this is called
    
      def failed_login(message)
        p "STRANGE"
        flash[:error] = message
        redirect_to :action => 'new'
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
        #session[:return_to] ? redirect_to_url(session[:return_to]) : redirect_to(default)
        session[:return_to] ? redirect_to(session[:return_to]) : redirect_to(default)
        session[:return_to] = nil
      end
    
      # Inclusion hook to make #current_account and #logged_in?
      # available as ActionView helper methods.
      #def self.included(base)
      #  base.send :helper_method, :current_account, :logged_in?
      #end

      # When called with before_filter :login_from_cookie will check for an :auth_token
      # cookie and log the account back in if apropriate
      def login_from_cookie
        p "------------"
        p "sick"
        p cookies
        return unless cookies[:auth_token] && !logged_in?
        p "sicker"
        account = Account.find_by_remember_token(cookies[:auth_token])
        if account && account.remember_token?
          account.remember_me
          self.current_account = account
          cookies[:auth_token] = { :value => self.current_account.remember_token , :expires => self.current_account.remember_token_expires_at }
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
=end
