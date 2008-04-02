module Younety
  module Rails #:nodoc:
    module ModelExtentions
      module ActsAsAdi
        module Share
          
          def find_all_web_applications
             Younety::Remote::Webapp.find_all_with_shares
          end

          def find_all_shares_by_webapp_id(webapp_id)
              Younety::Remote::Share.find_all_by_webapp_id(webapp_id)
          end

          def get_share_by_id(share_id)
             Younety::Remote::Share.find(share_id)
          end

          def share_it(share, values)
             share.share_it(self.adi_id, values)
          end
        
          def get_embed_share
             Younety::Remote::Share.find("Embed%20Code", :params => {:adi_id => @user_badge.adi_id }  )
          end

          def embed_code(format = "gif", pub = true, ismap = false )
            @embed_code ||=  self.adi.embed_code(format, pub, ismap )
          end
          
        end
      end
    end
  end
end