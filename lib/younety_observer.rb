class YounetyObserver < ActiveRecord::Observer
  observe Donation
  
  def after_create(donation)
    PointEntry.create(:youser_id => 1, :value => donation.account.donations.sum(:amount), :params => {:app_id => 1, :point_spec_id => 1  } ) 
  end
end