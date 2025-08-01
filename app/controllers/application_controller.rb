# frozen_string_literal: true

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

  def initialize
    @disable_unused_ui = Gatekeeper::Application.config.disable_unused_ui || true

    super
  end

  private

  def api_connection_options
    Gatekeeper::Application.config.api_connection_options
  end

  rescue_from Errno::ECONNREFUSED, with: :sequencescape_down

  def sequencescape_down
    @message = 'There is a problem with the connection to Sequencescape. Sequencescape may be down.'
    respond_to do |format|
      format.html { render 'pages/error', status: 500 }
      format.json { render json: { 'error' => @message }, status: 500 }
    end
  end
end
