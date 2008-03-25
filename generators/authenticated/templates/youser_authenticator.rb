class YouserAuthenticator < ActiveRecord::Base
  belongs_to :<%= file_name %>
 
  def before_create
    self.account_id = Account.find_or_create_by_authentication(identifier, 1, assign_attributes_hash).id
  end

  private
  # registration is a hash containing the valid sreg keys given above
  # use this to map them to fields of your user model
  def assign_attributes_hash
    return {}
  end
  
end
