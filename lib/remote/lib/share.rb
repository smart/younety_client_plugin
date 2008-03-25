module Younety
  module Remote
    class Share < YounetyResource
      #colection_name = "share"
      
      def self.find_all_by_webapp_id(webapp_id)
        Share.find(:all, :params => {:webapp_id => webapp_id})
      end
      
      def self.share_it(share_id, adi_id, params = {})
        Share.new(:id => share_id).share_it(adi_id, params)
      end
      
      def share_it(adi_id, params = {})
        response = self.post(:go, { :adi_id => adi_id, :share_it => params})
        if response.code == "200"
          return Hash.from_xml(response.body)['hash']
        else
          return false
        end 
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
