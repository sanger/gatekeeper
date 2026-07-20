# frozen_string_literal: true

##
# Helper methods for handling various API errors
module ApiError
  ##
  # Wrap any api searches to automatically handle a lack of results.
  def rescue_no_results(message)
    yield
  rescue Sequencescape::Api::ResourceNotFound, JsonApiClient::Errors::NotFound
    raise UserError::InputError, message
  end
end
