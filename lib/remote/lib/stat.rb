module Younety
  module Remote
    class Stat < YounetyResource
       self.site += '/adis/:adi_id'
       belongs_to :adi
       def self.sort(a = [])
        sorted  = []
        generic = nil 
        unknown = nil 
        a.each do |e|
          if e.name == 'Generic'  
    	 generic = e
    	 next
          end
          if e.name == 'Unknown'  
    	 unknown = e
    	 next
          end
          sorted << e

        end     
          sorted << generic 
          sorted << unknown 
          return sorted.compact
       end

    end
  end
end