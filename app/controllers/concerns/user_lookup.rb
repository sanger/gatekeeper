##
# Include in controllers to provide the #find_user filter
# This filter both provides swipecard lookup, and prevents unauthorised
# users from using the controller. Actions where a swipecard is not required
# should be excluded with eg. skip_before_action :find_user, :except => [:create]
module UserLookup

  private

  ##
  # Takes the user_swipecard parameter, and uses the api to find the corresponding user
  # Redirects to root with an error flash if no swipecard is found, or if it can't find a user
  def find_user
    swipecard_code = params[:user_swipecard]
    return user_error("User swipecard must be provided.") if swipecard_code.nil?
    begin
      @user = api.search.find(Settings.searches['Find user by swipecard code']).first(:swipecard_code=>swipecard_code)
    rescue StandardError => exception
      return user_error("User could not be found, is your swipecard registered?") if user_not_found?(exception.message)
      raise exception
    end
  end

  ##
  # The client-api-gem currently only raises standard errors. We check the message to determine the content
  def user_not_found?(message)
    message.include?("no resources found with that search criteria")
  end

  ##
  # Redirect to the root with a flash[:danger] of message
  def user_error(message)
    flash[:danger] = message
    redirect_to :root
    false
  end

end
