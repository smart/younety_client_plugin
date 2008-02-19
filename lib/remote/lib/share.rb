module Younety
  module Remote
    class Share < YounetyResource
      colection_name = "share"
      
      def self.share_it(share_id, adi_id, params = {})
        Share.new(:id => share_id).post(:go, { :adi_id => adi_id, :share_it => params})
      end
    end
  end
end