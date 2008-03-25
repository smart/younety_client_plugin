#require 'youser_authenticators/local_user'
#require 'youser_authenticators/facebook_youser'
#require 'youser_authenticators/open_id_youser'
#require 'youser_authenticators/local_user'
class YouserAuthenticator < ActiveRecord::Base
  belongs_to :account

  def before_create

    if account_id.nil?
      self.account_id = Account.find_or_create_by_authentication(identifier, self.class.authenticator_id, assign_attributes_hash).id
    else
      begin
        response =  Younety::Remote::YounetyToken.add_youser_authenticator(self.account.younety_token, {:identifier => identifier, :auth_type => self.class.authenticator_id})
        raise unless response == true
      rescue
        errors.add(:account, "unable to map auth to account" )
      end
    end
  end


  private
  # registration is a hash containing the valid sreg keys given above
  # use this to map them to fields of your user model
  def assign_attributes_hash
    return {}
  end
  
end

