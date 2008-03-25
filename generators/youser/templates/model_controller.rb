class <%= model_controller_class_name %>Controller < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  # If you want "remember me" functionality, add this before_filter to Application Controller
  before_filter :login_from_cookie

  # render new.rhtml
  def new
  end
  
  def finish_registration
    @<%= file_name %> = current_<%= file_name %>
  end
  
  def save_registration
    @<%= file_name %> = current_<%= file_name %>
    if current_<%= file_name %>.update_attributes(params[:<%= file_name %>])
      redirect_back_or_default('/')
      false
    else
      render :action => 'finish_registration'
    end
  end

  def create
    @local_user = LocalUser.new(params[:<%= file_name %>])
    if @local_user.save!
      successful_local_user_login
      return false
    else
      render :template => "/<%= controller_file_name %>/new"
    end
  end
  
<% if options[:include_activation] %>
  def activate
    self.current_<%= file_name %> = <%= class_name %>.find_by_activation_code(params[:activation_code])
    if logged_in? && !current_<%= file_name %>.activated?
      current_<%= file_name %>.activate
      flash[:notice] = "Signup complete!"
    end
    redirect_back_or_default('/')
  end
<% end %>
end
