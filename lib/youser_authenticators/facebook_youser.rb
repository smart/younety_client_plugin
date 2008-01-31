class FacebookYouser < YouserAuthenticator
  acts_as_facebook_user


  def self.find_or_create_by_facebook_session(sess)
    unless sess.is_ready?
      RAILS_DEFAULT_LOGGER.info "** RFACEBOOK WARNING: tried to use an inactive session for acts_as_facebook_user (in find_or_create_by_facebook_session)"
      return nil
    end
    
    # try to find, else create
    instance = FacebookYouser.find_or_initialize_by_facebook_uid(sess.session_user_id)
    
    instance.facebook_session = sess  
    # update (or create) the object and return it
    if !instance.save
      RAILS_DEFAULT_LOGGER.debug "** RFACEBOOK INFO: failed to update or create the Facebook user object in the database"
      return nil
    end
    return instance      
  end
  
  def self.find_or_initialize_by_facebook_session(sess)
    unless sess.is_ready?
      RAILS_DEFAULT_LOGGER.info "** RFACEBOOK WARNING: tried to use an inactive session for acts_as_facebook_user (in find_or_create_by_facebook_session)"
      return nil
    end
    # try to find, else initialize
    instance = FacebookYouser.find_or_initialize_by_facebook_uid(sess.session_user_id)
    instance.facebook_session = sess  
    return instance      
  end




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
