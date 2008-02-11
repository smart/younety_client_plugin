module Younety
  module Youser
    module Authenticators
      module FacebookAuthenticator

        def using_facebook?(facebook = params[:facebook])
          params[:facebook] ? true : false
        end
        
        
        def app_install_required
          respond_to do |accepts|
            accepts.all do
              store_location if session[:return_to].nil?
              redirect_to fbsession.get_install_url and return
            end
          end
          false
        end
        
        def invalid_account_join
          flash[:error] = "This facebook account is already registered, contact support@bokayme.com for additional support"
          redirect_to("/")
        end
  
        def facebook_authentication
          #ensure your token is good
          return nil if !fbsession.ready? 
          
          facebook_youser = FacebookYouser.find_or_initialize_by_facebook_session(fbsession)
          if session[:existing_youser] 
            #set id or fail if join conditions are bad
            (!facebook_youser.account_id.nil? && facebook_youser.account_id != current_account.id) ? invalid_account_join : facebook_youser.account_id = session[:existing_youser]
          end
          facebook_youser.save  
          self.current_account = Account.find(facebook_youser.account_id)
        end        
         
        def finish_facebook_login
          facebook_authentication      
          logged_in? ? successful_login : failed_login( "Failed Authentication")
        end
    
      end
    end
  end
end
