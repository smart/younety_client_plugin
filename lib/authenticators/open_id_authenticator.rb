module Younety
  module Youser
    module Authenticators
      module OpenIdAuthenticator


        # Pass optional :required and :optional keys to specify what sreg fields you want.
        # Be sure to yield registration, a third argument in the #authenticate_with_open_id block.
        # REMEMBER: a "required" field is not guaranteed to be returned by OpenID provider
        def open_id_authentication
          authenticate_with_open_id(params[:openid_url].strip, 
          :required => [ :nickname ],
          :optional => [ :email, :fullname ]) do |result, identity_url, registration|
            if result.successful?
              successful_openid_login(identity_url, registration)
            else
              failed_login(result.message || "Sorry could not log in with identity URL: #{identity_url}")
            end
          end
        end


        private
        def successful_openid_login(identity_url, registration = {})
          registration[:identity_url] = identity_url
          open_id_youser = OpenIdYouser.find_or_create_by_identity_url(registration)
          @account = Account.find(open_id_youser.account_id)
          self.current_account = @account
          successful_login
        end

        

          def denormalized_url(url)
            return url.gsub(%r{^https?://}, '').gsub(%r{/$},'')
          end

          def normalize_url(url)
            return OpenIdAuthentication.normalize_url(url)
          end

      end
    end
  end
end