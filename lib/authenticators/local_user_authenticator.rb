module Younety
  module Youser
    module Authenticators
      module LocalUserAuthenticator
 
        def using_local_user?(login = params[:login])
          params[:login] ? true : false
        end
        
        def local_user_authentication
          local_user = LocalUser.authenticate(params[:login], params[:password])
          if local_user 
             self.current_account = Account.find(local_user.account_id)
             if params[:remember_me] == "1" 
               current_account.remember_me
               cookies[:auth_token] = { :value => current_account.remember_token , :expires => current_account.remember_token_expires_at }
             end
             successful_login 
          else
            failed_login( "Failed Authentication")
          end
          
          return false
        end
        
      end
    end
  end
end
