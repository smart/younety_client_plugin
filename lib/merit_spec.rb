class MeritSpec << ActiveRecord::Base
  def before_create
    begin
      self.merit_spec_id = Younety::Remote::Merit.create(:name => name, :description => description, :icon => icon).id
    rescue
      self.errors.add("this is lame")
    end
  end
  
  
end