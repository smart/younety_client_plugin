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