module Younety
  module Remote
    class Share < YounetyResource
      self.site += '/adis/:adi_id'
      colection_name = "share"
    end
  end
end