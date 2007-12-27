# Include hook code here
#require File.dirname(__FILE__) + '/lib/acts_as_youser'
#require "acts_as_youser"
#require "remote/lib/point_spec"
#require "remote/lib/point_entry"
#require "remote/lib/younety_token"
#require "youser/youser"


require "model_extensions"
require "controller_extentions"
require "view_extentions"
require "youser_authenticator"
require "youser_authenticators/local_user"
require "youser_authenticators/facebook_youser"
require "youser_authenticators/open_id_youser"


# inject methods to Rails MVC classes
ActionView::Base.send(:include, Younety::Rails::ViewExtensions)
ActionController::Base.send(:include, Younety::Rails::ControllerExtensions)
ActiveRecord::Base.send(:include, Younety::Rails::ModelExtensions)

# load Facebook configuration file (credit: Evan Weaver)
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

p YOUNETY



require "remote/lib/younety_resource"
require "remote/lib/younety_token"
require "remote/lib/adi"
require "remote/lib/auth"
require "remote/lib/customization"
require "remote/lib/data_element"
require "remote/lib/share"
require "remote/lib/stat"
require "remote/lib/structure"
