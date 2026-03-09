# frozen_string_literal: true

class HealthController < ActionController::Base # rubocop:disable Rails/ApplicationController
  # Inherits from ActionController::Base to avoid implied dependencies on Sequencescape

  # Health endpoint
  #
  # Check connection to Sequencescape by making a health request, returns 200 if successful, or 502/504 if not.
  def show
    sequencescape_conn.get('/health')
    render plain: 'OK', status: :ok
  rescue Faraday::TimeoutError
    render plain: 'Connection to Sequencescape timed out', status: :gateway_timeout
  rescue Faraday::Error
    render plain: 'Sequencescape is unavailable', status: :bad_gateway
  end

  def sequencescape_conn
    @sequencescape_conn ||= Faraday.new(url: sequencescape_url) do |faraday|
      faraday.response :raise_error # raise Faraday::Error on status code 4xx or 5xx
    end
  end

  private

  def sequencescape_url
    Gatekeeper::Application.config.api_connection_options[:url]
  end
end
