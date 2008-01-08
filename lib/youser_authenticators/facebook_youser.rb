class FacebookYouser < YouserAuthenticator
  acts_as_facebook_user

  def self.authenticator_id
    1
  end

  def identifier
    self.facebook_uid
  end
  
  def assign_attributes_hash
    return_hash = {:nickname => self.first_name, :fullname => self.name}
    return return_hash
  end
  
  def friends(opts = ["first_name", "last_name"])
    friendUIDs = facebook_session.friends_get.uid_list

    # use those uids to get information about those users
    friend_names = {}
    friendsInfo = facebook_session.users_getInfo(:uids => friendUIDs, :fields => opts)
    friendsInfo.user_list.each do |userInfo|
    	friend_names[userInfo.uid] = userInfo.first_name + " " + userInfo.last_name
    end
    return friend_names
  end
  
  def appAdded?
    f = facebook_session.users_isAppAdded
    f.root.innerText == "1" ? true : false
  end
end
