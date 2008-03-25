module Younety
  module Remote
    class Structure < YounetyResource

      def example
        @adi = self.get(:example, :id => self.id )
      end
    end
  end
end
