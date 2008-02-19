module Younety
  module Remote
    class Webapp < YounetyResource
      
      def self.shares(webapp_id)
        Webapp.new(:id => webapp_id).get(:shares)
      end
    end
  end
end