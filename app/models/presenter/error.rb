# frozen_string_literal: true

##
# Handles errors that need to be returned to the user
# When working through a json interface. Ideally we
# want to hit this as little as possible, and catch most
# things that will end up here client side.
class Presenter::Error
  def initialize(exception)
    @message = exception.message
  end

  def output
    { 'error' => @message }
  end
end
