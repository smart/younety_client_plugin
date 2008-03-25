module Younety
  module Remote
    class Auth < YounetyResource
      self.site += "/adis/:adi_id"
      belongs_to :adi
    end
  end
end