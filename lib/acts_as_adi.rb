module Younety
  module Rails #:nodoc:
    module ModelExtentions
      module ActsAsAdi
      
        module ClassMethods

          def new_from_factory( factory )
            obj = self.new
            adi = Younety::Remote::Adi.create(:product_key => factory.structure_id, :auth_enabled => 0 )
            obj.send( (factory.class.to_s.underscore + '_id=').to_sym , factory.id )
            obj.adi_id = adi.id
            obj.public_id = Digest::MD5.hexdigest( ( self.count * rand ).to_s ).to_s
            obj
          end

        end

        module InstanceMethods 

          #local caching methods

          def adi 
            @adi ||= Younety::Remote::Adi.find(self.adi_id)
              raise(Exception, "adi not valid") if @adi.nil?
            @adi
          end

          def remote_path(ext = 'gif')
            "#{YOUNETY['url']}/adis/#{self.adi_id}.#{ext}" 
          end

          def draft_url(ext = 'gif')
            "#{YOUNETY['url']}/adis/#{self.adi_id}.#{ext}?draft=true" 
          end

          def save_thumbnails(thumbs = [], opts = {}) #TODO consolidate into a utilities directory
            opts[:ext]  ||= 'gif'
            image_data =  get_image_data_from_adiserver
            cache_original_file(image_data, opts) 
            thumbs.each { |thumb| save_thumbnail(image_data, thumb, opts ) } 
          end 

          def get_image_data_from_adiserver  #TODO consolidate into a utilities directory
            response = Net::HTTP.get_response(URI.parse(remote_path)) #TODO put in exception handling
            image_data = Magick::Image.from_blob(response.body).first  
            image_data
          end

          def cache_original_file(image_data, opts)#TODO consolidate into a utilities directory
            FileUtils.mkdir_p(cache_root)
            original_image_cache_path =  File.join(File.join(cache_root , "original.#{opts[:ext]}" ) )  
            image_data.write(original_image_cache_path)
          end

          def save_thumbnail(image_data, thumb , opts )#TODO consolidate into a utilities directory
            raise(Exception, "size name not specfied" ) unless thumb.has_key?(:name)
            raise(Exception, "width not specfied" ) unless thumb.has_key?(:width)
            raise(Exception, "height name not specfied" ) unless thumb.has_key?(:height)
            magick_method = opts[:magick_method] || 'resize_to_fit' # the default method is 'resize_to_fit' other valid ImageMagick transformations are possible
            path = File.join(cache_root, "#{thumb[:name]}.#{opts[:ext]}" )
            resized = image_data.send(magick_method.to_sym, thumb[:width], thumb[:height] )  
            FileUtils.mkdir_p(cache_root)
            resized.write(path)
          end

          def image_path(size = 'orginal', ext = 'gif')
            "cache/adis/#{self.id}/#{size}.#{ext}"
          end

          def cache_root
            "public/images/cache/adis/#{self.id}"
          end

           #adi methods 


          def embed_code(format = "gif", pub = true, ismap = false )
            @embed_code ||=  self.adi.embed_code(format, pub, ismap )
          end

          def statistics
            @statistics ||= self.adi.stats_summary
          end

          def adi_public_path #TODO investigate whether or not this is broken and/or if it's necessary?
            @adi_public_path ||= self.adi.public_path
          end

          def activate_adi 
            self.adi.activate
          end

          def deactivate_adi 
            self.adi.deactivate
          end

          def reset 
            self.adi.reset
          end

          #customization methods 

          def customizables #TODO figure out why this is not caching  
            @customizables ||= Younety::Remote::Customizable.find(:all, :params => { :structure_id => self.adi.structure_id } ) 
          end

          def customizable(customizable_id) 
             Younety::Remote::Customizable.find(:first, :params => {:id => customizable_id , :structure_id => self.adi.structure_id } ) 
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

          # share methods
          def find_all_shares_by_webapp_id(webapp_id)
            Younety::Remote::Share.find_all_by_webapp_id(webapp_id)
          end

          def share_adi(share_id, params = {})
            Share.share_it(share_id, self.adi_id, params )  
          end
        
        end
        
      end
    end
  end
end
