module Younety
  module Rails #:nodoc:
    module ActsAsAdi
      module Customization
                

        def customizables #TODO figure out why this is not caching  
          Younety::Remote::Customizable.find(:all, :params => { :structure_id => self.adi.structure_id } ) 
        end

        def get_customizable(customizable_id) 
          #TODO: This is ugly and inefficient, but it works for now.
          customizables = Younety::Remote::Customizable.find(:all, :params => { :structure_id => self.adi.structure_id } ) 
          customizables.each do |c|
            return c if c.id.to_s == customizable_id.to_s
          end
          return nil
        end

        def get_customization_option_value(customization, option_id) #this seems wrong
          customization.options.each do |option|
            return option.option if option.id.to_s == option_id.to_s
          end
          return ''
        end

        def get_customization_by_name(name) # Deprecated?
          Younety::Remote::Customization.find( URI::escape(name), :params => { :adi_id => self.adi_id } )
        end

        def set_customization_value(custom_name, value = '' , image_data = nil )
          Younety::Remote::Customization.set_value( self.adi_id , URI::escape(custom_name) , value, image_data )
        end

        def reset_customizations
          Younety::Remote::Customization.reset( self.adi_id )
          @customizations = {} #clear the cache of customizations
        end

        def commit_customizations
          Younety::Remote::Customization.commit( self.adi_id )
        end

        def icon_class 
          #TODO what do we do about this method
        end
        
      end
    end
  end
end