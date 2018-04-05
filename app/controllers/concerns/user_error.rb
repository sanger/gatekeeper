##
# Raise UserError::InputError to redirect a user to root
# The exception message will be returned to the user as a flash.

module UserError

  class InputError < StandardError; end

  def self.included(base)
    base.class_eval do
      include ApiError
      rescue_from UserError::InputError, with: :user_error

      ##
      # Redirect to the root with a flash[:danger] of message
      def user_error(exception)
        @message = exception.message
        respond_to do |format|
          format.html {
            flash[:danger] = @message
            redirect_to :root
          }
          format.json { render json: {'error' => @message}, status: 403 }
        end
        false
      end
    end
  end

end
