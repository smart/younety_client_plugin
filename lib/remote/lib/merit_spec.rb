module Younety
  module Remote
    class MeritSpec < YounetyClient
      self.site  += "/apps/:app_id"
    end
  end
end