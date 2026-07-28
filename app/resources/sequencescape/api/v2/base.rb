# frozen_string_literal: true

# Base class for Sequencescape API v2 client-side resources
class Sequencescape::Api::V2::Base < JsonApiClient::Resource
  # Set the API base url in the abstract base class
  self.site = Gatekeeper::Application.config.api_connection_options.url_v2

  # Set the API key in the headers for all requests
  api_key = Gatekeeper::Application.config.api_connection_options.authorisation
  connection_options[:headers] = { 'X-Sequencescape-Client-Id' => api_key }

  # Implement a find method that raises a ResourceNotFound error if no record is found.
  # Calls the standard find method, and raises if the result is nil.
  # Should this be rolled into the JsonApiClient gem?
  # For more details, see https://github.com/sanger/limber/pull/2559.
  # @raise [JsonApiClient::Errors::NotFound] if no record is found
  def self.find!(*)
    record = find(*)
    raise JsonApiClient::Errors::NotFound, 'Resource not found' if record.empty?

    record
  end
end
