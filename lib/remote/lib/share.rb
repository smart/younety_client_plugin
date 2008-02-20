module Younety
  module Remote
    class Share < YounetyResource
      colection_name = "share"
      
      def self.share_it(share_id, adi_id, params = {})
        Share.new(:id => share_id).post(:go, { :adi_id => adi_id, :share_it => params})
      end
      
      def icon_path
        icon_name = self.name.downcase.gsub(' ', '_').gsub(".","").gsub("\'", "").gsub("&", "and").gsub("_webapp", "").gsub("_share", "")
        if defined?(YOUNETY_LOCAL_ICON_PATH)
          #do something
        else
          "#{YOUNETY['url']}/images/icons/shares/#{icon_name}.png"
        end
      end
      
    end
  end
end