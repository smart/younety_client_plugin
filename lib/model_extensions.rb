require 'acts_as_structure'
require 'acts_as_youser'
require 'acts_as_adi'
require 'RMagick'      
module Younety
  module Rails
    module ModelExtensions
      
      # :section: ActsAs method mixing
      
      def self.included(base) # :nodoc:
        base.extend ActsAsMethods
      end

      module ActsAsMethods # :nodoc:all
        def acts_as_structure
          include Younety::Rails::ModelExtentions::ActsAsStructure::InstanceMethods
          extend Younety::Rails::ModelExtentions::ActsAsStructure::ClassMethods        
        end
        
        def acts_as_adi
          include Younety::Rails::ModelExtentions::ActsAsAdi::InstanceMethods
          extend Younety::Rails::ModelExtentions::ActsAsAdi::ClassMethods        
        end
      end
    end    
  end 
end
