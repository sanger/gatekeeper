##
# Helper methods for handling various api_errors
module ApiError

  ##
  # Wrap any api searches to automatically handle a lack of results.
  def rescue_no_results(message)
    begin
      yield
    rescue StandardError => exception
      raise UserError::InputError, message if no_search_result?(exception.message)
      raise exception
    end
  end

  private
  ##
  # The client-api-gem currently only raises standard errors. We check the message to determine the content
  def no_search_result?(message)
    message.include?("no resources found with that search criteria")
  end
end
