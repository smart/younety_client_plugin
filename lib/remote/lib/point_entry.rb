module Younety
  module Remote
    class Younety::PointEntry < YounetyClient
      # class = 
      self.site  =  "http://localhost:3100/apps/1/point_specs/:point_spec_id"
      site.user = "quentin" 
      site.password = "test"
    end
  end
end