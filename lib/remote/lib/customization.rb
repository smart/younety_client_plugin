module Younety
  module Remote
    class Customization < YounetyResource
        self.site += "/adis/:adi_id"
        belongs_to :adi
  
        attr_accessor :value
    
        def self.commit(adi_id)
          Customization.put(:commit, :adi_id => adi_id).code == "200" ? true : false 
        end
  
        #def commit
        #  Customization.put(:commit, :adi_id => @prefix_options[:adi_id])
        #end
        
        def self.set_value(adi_id, customization_name, value, image_data = nil)
          unless image_data.blank?
            custom = Customization.find(customization_name, :params => {:adi_id => adi_id})
            custom.image_data = image_data
            custom.draft_value = value
            custom.save
          else
            Customization.new(:id => customization_name, :adi_id => adi_id).put(:set_value, :customization => {:draft_value => value})
          end
        end
    
    
        def icon_class
          return "picture.png" if /picture/i.match(name)
          return "edges" if name  == "Top Color"
          return "edges" if name == "Bottom Color"
          return "fonts" if name == "Statement Text"
          return "images" if name == "Background Image"
          return "font.png"
        end
    end
  end
end