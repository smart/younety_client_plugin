module Younety
  module Remote
    class Category < YounetyResource
      self.site += "/apps/:app_id"
    end
  end
end