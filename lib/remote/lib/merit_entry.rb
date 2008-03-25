module Younety
  module Remote
    class MeritEntry < YounetyClient
      self.site  += "/apps/:app_id/merits/:merit_id"
    end
  end
end