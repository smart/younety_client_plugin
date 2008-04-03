module Younety
  module Rails
    module ActsAsStructure
    
      def self.included(base) # :nodoc:
        base.extend ActsAsMethods
      end
    
      module ActsAsMethods
      
        def acts_as_structure
          include Younety::Rails::ActsAsStructure::InstanceMethods
          extend Younety::Rails::ActsAsStructure::ClassMethods        
        end
    
      end
    
      module ClassMethods
      
      end  
  
      module InstanceMethods 

        def structure
          @structure ||= Younety::Remote::Structure.find(self.structure_id)
          raise(Exception, "structure not valid") if @structure.nil?
          @structure
        end

        def example_adi_id
          self.structure.example_adi_id
        end

        def example_path(ext = 'gif')
          "#{YOUNETY['url']}/adis/#{self.example_adi_id}.#{ext}" 
        end

        def customizables 
          #@customizables ||= structure.customizables
          #Younety::Remote::Customizable.find( URI::escape(name), :params => { :adi_id => self.adi_id } )
        end
      
        def customizable(name)
          customizables.select { |custom| custom.name == name}
        end
      
        def retrieve_example_adi_file_data_from_adiserver(ext = "gif")
          begin
            Magick::ImageList.new(URI.parse(example_path(ext)))  # I think you can do this
          rescue
            raise(Exception, "Unable to load remote adi")
          end
            #response = Net::HTTP.get_response(URI.parse(remote_path)) #TODO put in exception handling
            #image_data = Magick::Image.from_blob(response.body).first  
            #image_data
        end

        def save_thumbnails(thumbs = [], opts = {}) #TODO consolidate into a utilities directory
          opts[:ext]  ||= 'gif'
          image_data = self.retrieve_example_adi_file_data_from_adiserver(opts[:ext])
          cache_original_file(image_data, opts) 
          thumbs.each { |thumb| save_thumbnail(image_data, thumb, opts ) } 
        end

        def cache_image_customization_options(sizes = [] , opts = {})    
          customizables = Younety::Remote::Customizable.find(:all, :params => { :structure_id => self.structure_id } ) 
          customizables.each do |customizable|
              cache_customizable_options(customizable) if customizable.customizable_type =~ /image/i
          end
        end

        def cache_customizable_options(customizable, opts = {})
          customizable.options.each do |option| 
             FileUtils.mkdir_p( option_cache_path(customizable) )
             ext = option.option.match(/.*\.(\w+)/)[1]
             remote_path =  "#{YOUNETY['url']}/structures/#{self.structure_id}/customizables/#{customizable.id}/options/#{option.id}.#{ext}"
             response = Net::HTTP.get_response(URI.parse(remote_path)) #TODO put in exception handling
             image_data = Magick::Image.from_blob(response.body).first  
             image_data.write(customizable_option_cache_file_path(customizable, option) )
          end
        end

        def option_cache_path(customizable)
           "#{cache_root}/options/#{customizable.id.to_s}/" 
        end

        def customizable_option_cache_file_path(customizable, option)
           File.join(option_cache_path(customizable) +  option.option) 
        end

        def remove_thumbnails
          FileUtils.rm_r(cache_root) 
        end

        def cache_original_file(image_data, opts)
          FileUtils.mkdir_p(cache_root)
          original_image_cache_path =  File.join(File.join(cache_root , "original.#{opts[:ext]}" ) )#TODO consolidate into a utilities directory  
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
          "cache/structures/#{self.structure_id}/#{size}.#{ext}"
        end


        def cache_root
          "#{YOUNETY['image_cache_path']}structures/#{self.structure_id}"
        end

      end
    end
  end
end

