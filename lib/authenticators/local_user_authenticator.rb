module Younety
  module Youser
    module Authenticators
      module LocalUserAuthenticator
 
        def using_local_user?(login = params[:login])
          params[:login] ? true : false
        end
        
        def local_user_authentication
          @local_user = LocalUser.authenticate(params[:login], params[:password])
          @local_user ? successful_local_user_login : failed_login( "Failed Authentication")
          return false
        end

        def successful_local_user_login
          new_account = Account.find(@local_user.account_id)
          self.current_account = new_account
          
          if params[:remember_me] == "1" 
            current_account.remember_me
            cookies[:auth_token] = { :value => current_account.remember_token , :expires => current_account.remember_token_expires_at }
          end
  
          successful_login
          return false
        end
        
      end
    end
  end
end
