module UserLookup

  private

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

  def user_not_found?(message)
    message.include?("no resources found with that search criteria")
  end

  def user_error(message)
    flash[:danger] = message
    redirect_to :root
    false
  end

end
