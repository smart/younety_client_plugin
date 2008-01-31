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
        
        def add_facebook_to_account
          self.current_account = Account.find(session[:existing_youser])
          fb = FacebookYouser.find_or_initialize_by_facebook_session(fbsession)
          if !fb.account_id.nil? && fb.account_id != current_account.id 
            flash[:notice] = "This Facebook Account is already mapped to another account email admin@bokayme.com if you didn't expect this"
            redirect_back_or_default("/")
            return false
          end
          fb.account_id = current_account.id
          fb.save
          current_account.reload
          session[:existing_user] = nil
        end
  
        def finish_facebook_login
          if session[:existing_youser]
           add_facebook_to_account 
          else
            facebook_user = FacebookYouser.find_or_create_by_facebook_session(fbsession)
            self.current_account = Account.find(facebook_user.account_id)
            unless self.current_account.facebook.appAdded?
              redirect_to fbsession.get_install_url and return
            end
          end
          logged_in? ? successful_login : failed_login( "Failed Authentication")
        end
    
      end
    end
  end
end
