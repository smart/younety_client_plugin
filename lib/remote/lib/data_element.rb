module Younety
  module Remote
    class DataElement  < YounetyResource
      self.site += "/adis/:adi_id"
      belongs_to :scope, :polymorphic => true
    end
  end 
end 