module Younety
  module Rails #:nodoc:
    module ModelExtentions
      module ActsAsYouser
        REQUIRED_FIELDS = ['nickname' , 'primary_email']
      
          
        module ClassMethods
          attr_accessor :create_auth_token
          attr_accessor :create_authenticator
        
          def find_by_authentication(identifier, auth_type)
            token = Younety::Remote::YounetyToken.create({:identifier => identifier, :authenticator_id => auth_type}).id
            Account.find_by_younety_token(token, :include => :account)
          end
          
          def find_or_create_by_authentication(identifier, auth_type, attribs = {})
            token = Younety::Remote::YounetyToken.create({:identifier => identifier, :authenticator_id => auth_type}).id
            attribs[:younety_token] = token
            Account.find_or_create_by_younety_token(attribs)
          end
          
          # Encrypts some data with the salt.
          def encrypt(password, salt)
            Digest::SHA1.hexdigest("--#{salt}--#{password}--")
          end

          def validate_on_update
            REQUIRED_FIELDS.each do |field|
              errors.add(field, "is required and cannot be blank") if @attributes[field].nil? || @attributes[field].blank?
            end
          end
        end
      
        module InstanceMethods
        
          #check if the record is complete you will want to extend this to match the requirements for making an account in your system
          def complete?
            REQUIRED_FIELDS.each do |field|
              return false if @attributes[field].nil? || @attributes[field].blank?
            end
            return true
          end

          def remember_token?
            remember_token_expires_at && Time.now.utc < remember_token_expires_at 
          end

          # These create and unset the fields required for remembering users between browser closes
          def remember_me
            remember_me_for 2.weeks
          end

          def remember_me_for(time)
            remember_me_until time.from_now.utc
          end

          def remember_me_until(time)
            self.remember_token_expires_at = time
            self.remember_token            = encrypt("#{nickname}--#{remember_token_expires_at}")
            save(false)
          end

          def forget_me
            self.remember_token_expires_at = nil
            self.remember_token            = nil
            save(false)
          end
          
          # Encrypts the password with the user salt
          def encrypt(password)
            self.class.encrypt(password, salt)
          end
        end
      end
    end
  end
end