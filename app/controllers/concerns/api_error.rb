##
# Helper methods for handling various api_errors
module ApiError

  ##
  # Wrap any api searches to automatically handle a lack of results.
  def rescue_no_results(message)
    begin
      yield
    rescue Sequencescape::Api::ResourceNotFound => exception
      raise UserError::InputError, message
    end
  end

end
