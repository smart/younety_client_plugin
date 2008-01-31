module Younety
  module Remote
    class YounetyToken < YounetyResource
      
      def self.add_youser_authenticator(younety_token, youser_authenticator = {})
        response = YounetyToken.new(:id => younety_token).put(:add_youser_authenticator, :youser_authenticator => youser_authenticator)
        return  response.code == "200" ? true : response
      end
      
    end
  end
end