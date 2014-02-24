##
# Helper methods for handling various api_errors
module ApiError
  ##
  # The client-api-gem currently only raises standard errors. We check the message to determine the content
  def no_search_result?(message)
    message.include?("no resources found with that search criteria")
  end
end
