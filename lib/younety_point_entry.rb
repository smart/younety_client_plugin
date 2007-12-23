
class YounetyPointEntry < ActiveRecord::Base
  belongs_to :younety_point_spec


  def before_save
    begin
      # only send if value has changed
      unless self.value == self.last_sent_value
        pe = Younety::Remote::PointEntry.create(:youser_authenticator_app_id => auth_token, :point_spec_id => point_spec.point_spec_id, :value => value)
        self.point_entry_id = pe.id
      end
    rescue
      self.errors.add("an error occurred")
    end
  end
end
