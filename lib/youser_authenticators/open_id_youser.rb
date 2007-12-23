class OpenIdYouser < YouserAuthenticator

  def authenticator_id
    2
  end

  def identifier
    self.identity_url
  end

  # registration is a hash containing the valid sreg keys given above
  # use this to map them to fields of your user model
  def assign_attributes_hash
    return_hash = {}
    { 
      :nickname  => 'nickname', 
      :primary_email  => 'email', 
      :fullname   => 'fullname' 
    }.each do |model_attribute, registration_attribute|
      return_hash[model_attribute] = self.send("#{registration_attribute}")
    end
    return return_hash
  end
    
end
