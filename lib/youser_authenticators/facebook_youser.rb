class FacebookYouser < YouserAuthenticator
  acts_as_facebook_user

  def self.authenticator_id
    1
  end

  def identifier
    self.facebook_uid
  end
  
  def assign_attributes_hash
    return_hash = {:nickname => self.first_name, :fullname => self.name}
    return return_hash
  end
end
