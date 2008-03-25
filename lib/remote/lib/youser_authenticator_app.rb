module Younety
  module Remote
    class YouserAuthenticatorApp < YounetyClient
      self.site += "/apps/:app_id"
    end
  end
end