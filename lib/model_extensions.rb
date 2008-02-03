require "acts_as_youser"
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
      end
      
      
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