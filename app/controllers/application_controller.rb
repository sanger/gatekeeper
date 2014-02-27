##
# Provides global application controls, such as the api configuration

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include Sequencescape::Api::Rails::ApplicationController
  include UserError
  include UserLookup
  include ApiError

  private

  def api_connection_options
    Gatekeeper::Application.config.api_connection_options
  end

  rescue_from Errno::ECONNREFUSED, :with => :sequencescape_down

  def sequencescape_down
    @message = "There is a problem with the connection to Sequencescape. Sequencescape may be down."
    render 'pages/error', :status => 500
  end

end
