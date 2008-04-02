module Younety
  module Remote
    class Option < YounetyResource
      self.site += "structures/:structure_id/customizables/:customizable_id"

      def get_image_data(option)
          p '------------------------'
          p '------------------------'
          p  "get image data called with " 
          p  option
          p '------------------------'
          p '------------------------'
          return []
      end

    end
  end
end
