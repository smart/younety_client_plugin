module Younety
  module Remote
    class Adi < YounetyResource
      has_many :customizations
      has_many :shares
      has_many :data_elements
      has_many :auths
      has_many :stats
    
      def activate
       Adi.put(:activate, :id => self.id ).code == "200" ? true : false 
       #activate_path = self.class.collection_path(self.prefix_options) + ";activate"
       #(connection.put(activate_path, to_xml).code == "200") ? true : false
      end
  
      def deactivate
       Adi.put(:deactivate, :id => self.id ).code == "200" ? true : false 
       #deactivate_path = self.class.collection_path(self.prefix_options) + ";deactivate"
       #(connection.put(deactivate_path, to_xml).code == "200") ? true : false
      end

      def reset 
       Adi.put(:reset, :id => self.id ).code == "200" ? true : false 
       #deactivate_path = self.class.collection_path(self.prefix_options) + ";deactivate"
       #(connection.put(deactivate_path, to_xml).code == "200") ? true : false
      end
      
      def stats_summary
        self.get(:stats_summary)
      end
     
      def customizations
       self.get(:customizations)
      end
 
      def customizables
       a = []
       self.get(:customizations).each do |customization|
           a << Customization.new(customization) 
        end
       a
      end
      
      def embed_code(format = "gif", pub = true, ismap = false)
        self.get(:embed_code, {:adi_format => format, :public => pub, :ismap => ismap})
      end
  
      def public_path
       "#{YOUNETY['url']}/badges/#{self.public_id}" 
      end
  
      #depricated
      def code_snippet
       embed_code
      end
    end

    class AdiCustomization 
       attr_accessor :id,:name,:default_value,:current_value,:custom_options,:user_tag,:customizable_type,:draft_value,:validation_rules,:options
       def initialize(hash)
         hash.each_pair do |k,v|
            self.send( k + '=', v)  
          end
          self.options=[]
          return if self.custom_options.nil?
          self.custom_options.each do |name, value|
            self.options << CustomizationOption.new(name, value)
          end
       end
     end

     class CustomizationOption
        attr_accessor :name, :value
        def initialize(name, value)
          self.name  = name 
          self.value = value 
        end
     end
 
  end
end
