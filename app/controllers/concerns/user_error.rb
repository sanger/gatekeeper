##
# Raise UserError::InputError to redirect a user to root
# The exception message will be returned to the user as a flash.

module UserError

  class InputError < StandardError; end

  def self.included(base)
    base.class_eval do
      include ApiError
      rescue_from UserError::InputError, :with => :user_error

      ##
      # Redirect to the root with a flash[:danger] of message
      def user_error(exception)
        flash[:danger] = exception.message
        redirect_to :root
        false
      end
    end
  end

end
