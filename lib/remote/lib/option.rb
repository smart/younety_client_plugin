module Younety
  module Remote
    class Option < YounetyResource
      self.site += "structures/:structure_id/customizables/:customizable_id"
    end
  end
end
