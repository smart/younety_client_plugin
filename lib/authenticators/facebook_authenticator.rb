module Younety
  module Youser
    module Authenticators
      module FacebookAuthenticator

        def using_facebook?(facebook = params[:facebook])
          params[:facebook] ? true : false
        end
  
        def facebook_authentication
          require_facebook_login
          
          #return false
          return fbsession.is_valid? ? finish_facebook_login : false
        end
  
        def finish_facebook_login
          facebook_user = FacebookYouser.find_or_create_by_facebook_session(fbsession)
          self.current_account = Account.find(facebook_user.account_id)
          unless self.current_account.facebook.appAdded?
            redirect_to fbsession.get_install_url and return
          end
          logged_in? ? successful_login : failed_login( "Failed Authentication")
        end
    
      end
    end
  end
end
