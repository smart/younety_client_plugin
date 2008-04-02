module Younety
  module Remote
    class YounetyResource < ActiveResource::Base
      self.site = YOUNETY['url']
      site.user = YOUNETY['user']
      site.password = YOUNETY['pass']
      
      def self.has_many(association_id, options = {})
          define_method(association_id) do
            klass = (options[:class_name] || association_id.to_s.classify)
            #modulelize = "SympactAdiClient::#{klass}"
            klass.constantize.find(:all, :from => "/#{self.class.collection_name}/#{id}/#{association_id}.xml")
          end
        end

      def self.has_one(association_id, options = {})
          define_method(association_id) do
            klass = (options[:class_name] || association_id.to_s.classify)
            klass.constantize.find(:one, :from => "/#{self.class.collection_name}/#{id}/#{association_id}.xml")
          end
        end

        def self.belongs_to(association_id, options = {})
          if options[:polymorphic] == true
             define_method(association_id) do
               klass = send("#{association_id}_type").classify
               identifier = send("#{association_id}_id")
               klass.constantize.find(identifier) if identifier
             end
          else
            define_method(association_id) do
              klass = (options[:class_name] || association_id.to_s.classify)
              foreign_key = send(klass.foreign_key)
              klass.constantize.find(foreign_key) if foreign_key
            end
          end
        end
    end
  end
end
