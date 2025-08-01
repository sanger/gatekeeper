# frozen_string_literal: true

class Sequencescape::Api::V2::Base < JsonApiClient::Resource
  self.site = Gatekeeper::Application.config.api_connection_options.url_v2
  connection_options[:headers] = { "X-Sequencescape-Client-Id" => Gatekeeper::Application.config.api_connection_options.authorisation }
end