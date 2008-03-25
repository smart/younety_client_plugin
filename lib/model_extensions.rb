require "acts_as_youser"
require 'RMagick'      
module Younety
  module Rails
    module ModelExtensions
      
      # :section: ActsAs method mixing
      
      def self.included(base) # :nodoc:
        base.extend ActsAsMethods
      end

      module ActsAsMethods # :nodoc:all
        def acts_as_younety_user
          include Younety::Rails::ModelExtensions::ActsAsYounetyUser::InstanceMethods
          extend Younety::Rails::ModelExtensions::ActsAsYounetyUser::ClassMethods
        end
        
        def acts_as_youser
          has_many :youser_authenticators
          has_one :facebook, :class_name => "FacebookYouser", :foreign_key => "account_id"
          #with_options :foreign_key => 'parent_id' do |m|
          #  m.has_many   :thumbnails, :dependent => :destroy, :class_name => options[:thumbnail_class].to_s
          #  m.belongs_to :parent, :class_name => self.base_class.to_s
          #end
          
          include Younety::Rails::ModelExtentions::ActsAsYouser::InstanceMethods
          extend Younety::Rails::ModelExtentions::ActsAsYouser::ClassMethods
        end  
        
        def acts_as_point_spec(options = nil)
          include Younety::Rails::ModelExtensions::ActsAsPointSpec::InstanceMethods
          extend Younety::Rails::ModelExtensions::ActsAsPointSpec::ClassMethods
          @point_spec_id = options[:point_spec_id] || (raise Exception)
          #@youser_association = options[:youser_association] || raise Exception
          @point_spec_type = options[:point_spec_type] || "SumPointSpec"
          @value_column = options[:value_column]  || :value 
        end

        def acts_as_structure
          include Younety::Rails::ModelExtensions::ActsAsStructure::InstanceMethods
          extend Younety::Rails::ModelExtensions::ActsAsStructure::ClassMethods
        end

        def acts_as_adi
         p 'hi'
          include Younety::Rails::ModelExtensions::ActsAsAdi::InstanceMethods
          extend Younety::Rails::ModelExtensions::ActsAsAdi::ClassMethods
        end

      end

   module ActsAsStructure
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

         ADISERVER = "http://0.0.0.0:3001" #TODO figure out where this constant should be set , is this younety.yml config thing?

         def remote_path(ext = 'gif')
           "#{ADISERVER}/adis/#{self.example_adi_id}.#{ext}" 
         end


         def retrieve_example_adi_file_data_from_adiserver
            response = Net::HTTP.get_response(URI.parse(remote_path)) #TODO put in exception handling
            image_data = Magick::Image.from_blob(response.body).first  
            image_data
         end

         def save_thumbnails(thumbs = [], opts = {}) #TODO consolidate into a utilities directory
           opts[:ext]  ||= 'gif'
           image_data = self.retrieve_example_adi_file_data_from_adiserver
           cache_original_file(image_data, opts) 
           thumbs.each { |thumb| save_thumbnail(image_data, thumb, opts ) } 
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
            "cache/structures/#{self.id}/#{size}.#{ext}"
         end


         def cache_root
           "public/images/cache/structures/#{self.id}"
         end


     end

   end #end module ActsAsStructure


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

         ADISERVER = "http://0.0.0.0:3001" #TODO figure out where this constant should be set , is this younety.yml config thing?

         #local caching methods

         def adi 
           @adi ||= Younety::Remote::Adi.find(self.adi_id)
             raise(Exception, "adi not valid") if @adi.nil?
           @adi
         end

         def remote_path(ext = 'gif')
           "#{ADISERVER}/adis/#{self.adi_id}.#{ext}" 
         end

         def draft_url(ext = 'gif')
           "#{ADISERVER}/adis/#{self.adi_id}.#{ext}?draft=true" 
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

         def customizables  
           @customizables ||= self.adi.customizables 
         end
       
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
         def get_customization_by_name(name)
           Younety::Remote::Customization.find( URI::escape(name), :params => { :adi_id => self.adi_id } )
         end


         def set_customization(name, value = '' , image_data = nil )
             Younety::Remote::Customization.set_value(self.adi_id, name, value, image_data )
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

   end #end module ActsAsAdi
      
      
     module ActsAsPointSpec
        
          module ClassMethods
             attr_accessor :point_spec_id
              attr_accessor :point_spec_type
              # I would like to replace this with a way of detecting the class that implmements acts_as_younety_youser
              attr_accessor :youser_association
              attr_accessor :value_column
            #implement
            def sync()
              self.find(:all).each do |selfer|
                selfer.sync
              end
            end
            
            #generate sync xml
            def sync_xml()
            end
          
            def score_all()
            end
          end
          
          module InstanceMethods
            
            def calculate
              youser.send(self.class.table_name).sum(@value_column)
            end
            
            def sync
              PointEntry.create(:youser_authenticator_app => youser.auth_token, :point_spec_id => point_spec_id, :app => YOUNETY_APP, :value => calculate)
            end 
          end
        end
      
      
      ##################################################################
      ##################################################################
      # :section: Acts As Facebook User
      ##################################################################
      module ActsAsYounetyUser
        
        ######################
        module ClassMethods
             
          def set_auth_token_for_all()
            yousers = self.find(:all)
            yousers.each do |youser|
              youser.get_auth_token()
              youser.save
            end
          end       
                            
        end
      
        ######################
        module InstanceMethods
          
          #def auth_token
          #  return self['auth_token'] ||= get_auth_token
          #end
          
          def get_auth_token()
            #begin
            #try to get a facebook id
            identifier =  self.get_facebook_uid
            if identifier
              self.auth_token = Younety::Remote::YounetyToken.create(:type => "Facebook", :identifier => identifier, :app_id => 1).id
              self.save
              return self['auth_token']
            end
            
            #try to get an open ID
            identifier = self.get_open_id
            if identifier
              self.auth_token = Younety::Remote::YouserAuthenticatorApp.create(:type => "OpenId", :identifier => identifier, :app_id => 1).id
              self.save
              return self.auth_token
            end
            
            #use access code method
            identifier = self.get_username
            self.auth_token = Younety::Remote::YouserAuthenticatorApp.create(:type => "AccessCode", :identifier => identifier, :app_id => 1).youser_authenticator_id
            self.save
            return self.auth_token
            
            #rescue
            #  RAILS_DEFAULT_LOGGER.debug "** YOUNETY INFO: could not create an auth key check your younety settings"
            #  return false
            #end
          end
          
          
          def scores
            score_array = {}
            @specs = LocalPointSpec.find(:all)
            @specs.each do |spec|
              score_array[spec.name] = spec.calculate(self)
            end
            return score_array
          end
                      
        end
        
      end
        
          
             
    end    
  end 
end
