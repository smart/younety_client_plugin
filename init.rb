# AUTHORS:
# - Sympact Development (Steve Martocci, Elliott Blatt, Lourens Van Der Jagt)

# LICENSE:
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
# 
# Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
# 
# Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
# 
# Neither the name of the original author nor the names of contributors
# may be used to endorse or promote products derived from this software
# without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


# You can override these defaults in younety.yml
::YOUNETY = { "image_cache_path" => "public/cache/"}
begin
  yamlFile = YAML.load_file("#{RAILS_ROOT}/config/younety.yml")
rescue Exception => e
  raise StandardError, "config/younety.yml could not be loaded."
end

if yamlFile
  if yamlFile[RAILS_ENV]
    YOUNETY.merge!(yamlFile[RAILS_ENV])
  else
    raise StandardError, "config/younety.yml exists, but doesn't have a configuration for RAILS_ENV=#{RAILS_ENV}."
  end
else
  raise StandardError, "config/younety.yml does not exist."
end

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

require "remote/lib/younety_resource"
require "remote/lib/younety_token"
require "remote/lib/adi"
require "remote/lib/auth"
require "remote/lib/customization"
require "remote/lib/data_element"
require "remote/lib/share"
require "remote/lib/stat"
require "remote/lib/structure"
require "remote/lib/webapp"
require "remote/lib/customizable"
require "remote/lib/option"
