module Younety
  module Remote
    class PointSpec < YounetyClient
    
      def self.score(point_spec_id, auth_token, score)
        Younety::PointEntry.create(:point_spec_id => point_spec_id, :youser_authenticator_app_id => auth_token, :value => score)
      end
    end
  end
end