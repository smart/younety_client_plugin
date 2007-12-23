class <%= class_name %>< ActiveRecord::Base
  acts_as_youser
  # you can extend this
  REQUIRED_FIELDS = ['nickname', 'fullname', 'primary_email']

 
end
