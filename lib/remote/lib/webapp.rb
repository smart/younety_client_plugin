module Younety
  module Remote
    class Webapp < YounetyResource
      
      def self.shares(webapp_id)
        Webapp.new(:id => webapp_id).get(:shares)
      end
      
      def self.find_all_with_shares
        Webapp.find(:all, :params => {:with_shares => "true"})
      end
      
      def icon_path
        icon_name = self.name.downcase.gsub(' ', '_').gsub(".","").gsub("\'", "").gsub("&", "and").gsub("_webapp", "").gsub("_share", "")
        if defined?(YOUNETY_LOCAL_ICON_PATH)
          #do something
        else
          "#{YOUNETY['url']}/images/icons/webapps/#{icon_name}.png"
        end
      end
    end
  end
end
