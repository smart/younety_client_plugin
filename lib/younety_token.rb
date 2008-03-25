class YounetyToken < YounetyClient
  
  #need to strip out dangerous info
  def self.create(identifier, authenticator_id)
    token = Younety::Remote::YounetyToken.create(:app_id => 1, :authenticator_id => authenticator_id, :identifier => identifier)
    return token.id
  end
  
end