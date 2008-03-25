class YounetyPointSpec < ActiveRecord::Base
    has_many :younety_point_entries
  
    def self.sync_from_remote
      specs = Younety::Remote::PointSpec.find(:all)
      specs.each do |spec|
        new_spec = YounetyPointSpec.find_or_initialize_by_point_spec_id(spec.id)
        new_spec.name = spec.name
        new_spec.description = spec.description
        new_spec.save
      end
    end
    
    def before_create
      begin
        self.point_spec_id = Younety::Remote::PointSpec.create(:name => name, :description => description).id
      rescue
        self.errors.add("this is lame")
      end
    end
  
    def calculate(account)
      point_value = account.donations.sum(:amount)
      self.local_point_entries.create(:auth_token => account.auth_token, :value => point_value)
      return point_value
    end
  
  end