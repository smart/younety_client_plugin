module Younety
  module Remote
    class Customizable < YounetyResource
      self.site += "/structures/:structure_id"

      def options #TODO is this caching or not?
         Option.find(:all, :params => {:structure_id => self.prefix_options[:structure_id] , :customizable_id  => self.id } )
      end

    end
  end
end
