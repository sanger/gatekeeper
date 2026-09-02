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

  # When fetching all records, iteratively fetch each next page and combine them into a single result set.
  def self.all
    result_set = super
    all_results = result_set.to_a

    while next_page?(result_set)
      result_set = result_set.pages.next
      all_results += result_set.to_a
    end

    all_results
  end

  # Check if the given result set has a next page of results.
  # @param result_set [JsonApiClient::ResultSet] the result set to check for a next page
  # @return [Boolean] true if there is a next page, false otherwise
  def self.next_page?(result_set)
    result_set.links.link_url_for('next')
    true
  rescue KeyError
    false
  end
end
