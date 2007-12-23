module Younety
  module Rails
    module ViewExtensions
      
      def current_account
        @current_account ||= (session[:account] && Account.find_by_id(session[:account])) || :false
      end
      
      def logged_in?
        current_account != :false
      end
    end
  end
end