# frozen_string_literal: true

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
    raise UserError::InputError, 'User swipecard must be provided.' if swipecard_code.nil?
    rescue_no_results('User could not be found, is your swipecard registered?') do
      @user = api.search.find(Settings.searches['Find user by swipecard code']).first(swipecard_code: swipecard_code)
    end
  end
end
