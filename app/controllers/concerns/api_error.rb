# frozen_string_literal: true

##
# Helper methods for handling various api_errors
module ApiError
  ##
  # Wrap any api searches to automatically handle a lack of results.
  def rescue_no_results(message)
    yield
  rescue Sequencescape::Api::ResourceNotFound
    raise UserError::InputError, message
  end
end
