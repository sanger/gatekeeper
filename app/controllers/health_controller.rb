# frozen_string_literal: true

class HealthController < ActionController::Base # rubocop:disable Rails/ApplicationController
  # Inherits from ActionController::Base to avoid any dependencies on Sequencescape
  def show
    render plain: 'OK'
  end
end
