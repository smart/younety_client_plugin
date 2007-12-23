module Younety
  module Remote
    class YounetyResource < ActiveResource::Base
      begin
        yamlFile = YAML.load_file("#{RAILS_ROOT}/config/younety.yml")
      rescue Exception => e
        raise StandardError, "config/younety.yml could not be loaded."
      end

      if yamlFile
        if yamlFile[RAILS_ENV]
          YOUNETY =  yamlFile[RAILS_ENV]
        else
          raise StandardError, "config/younety.yml exists, but doesn't have a configuration for RAILS_ENV=#{RAILS_ENV}."
        end
      else
        raise StandardError, "config/younety.yml does not exist."
      end
      
      self.site = YOUNETY['url']
      site.user = YOUNETY['user']
      site.password = YOUNETY['pass']
    end
  end
end
