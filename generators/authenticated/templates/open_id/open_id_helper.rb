module OpenIdHelper


  # Pass optional :required and :optional keys to specify what sreg fields you want.
  # Be sure to yield registration, a third argument in the #authenticate_with_open_id block.
  # REMEMBER: a "required" field is not guaranteed to be returned by OpenID provider
  def open_id_authentication
    authenticate_with_open_id(params[:openid_url], 
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
      unless @<%= file_name %> = <%= class_name %>.find_by_youser(identity_url, "OpenId")
        @<%= file_name %> = <%= class_name %>.new(:create_auth_token => identity_url, :create_authenticator => "OpenId")
        assign_open_id_attributes(identity_url, registration)
      end
      self.current_<%= file_name %> = @<%= file_name %>
      successful_login
    end
    
    # registration is a hash containing the valid sreg keys given above
    # use this to map them to fields of your user model
    def assign_open_id_attributes(identity_url, registration)
      { 
        :nickname  => 'nickname', 
        :primary_email  => 'email', 
        :fullname   => 'fullname' 
      }.each do |model_attribute, registration_attribute|
        unless registration[registration_attribute].blank?
          @<%= file_name %>.send("#{model_attribute}=", registration[registration_attribute])
        end
      end
      # CHOOSE - Uncomment to clean up logins as desired for application; 
      #          else login = nickname, e.g. "Dr Nic" instead of 'drnic'
      # @user.login.gsub!(/\W+/,'').downcase unless @user.login.blank?
      @<%= file_name %>.save
    end
    
    def denormalized_url(url)
      return url.gsub(%r{^https?://}, '').gsub(%r{/$},'')
    end
 
  def normalize_url(url)
    return OpenIdAuthentication.normalize_url(url)
  end

end
