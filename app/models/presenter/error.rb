##
# Handles errors that need to be returned to the user
# When working through a json interface. Ideally we
# want to hit this as little as possible, and catch most
# things that will end up here client side.
class Presenter::Error

  def initialize(message)
    @message = message
  end

  def output
    {'error'=>@message}
  end
end
