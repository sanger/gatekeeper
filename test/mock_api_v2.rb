# frozen_string_literal: true

# Standard methods for mocking the API in unit tests
module MockApiV2
  # Mock a user for tests.
  #
  # This will mock the API to return a user with the given swipecard and uuid when searched for.
  #
  # Usage:
  #
  #  ```rb
  #  MockApiV2.mock_user(swipecard: '123456789', first_name: 'Test', last_name: 'User')
  #  ```
  def self.mock_user(swipecard: '123456789', uuid: '11111111-2222-3333-4444-555555555555', login: 'testuser',
                     first_name: 'Test', last_name: 'User')
    mock_user = Sequencescape::Api::V2::User.new(swipecard:, uuid:, login:, first_name:, last_name:)
    Sequencescape::Api::V2::User.expects(:find!).with(user_code: swipecard).returns([mock_user])
    mock_user
  end

  # Mock a missing user for tests.
  #
  # This will mock the API to raise a NotFound error when searching for a user with the given swipecard.
  #
  # Usage:
  #
  #  ```rb
  #  MockApiV2.mock_missing_user(swipecard: '123456789')
  #  ```
  def self.mock_missing_user(swipecard: '123456789')
    Sequencescape::Api::V2::User.expects(:find!).with(user_code: swipecard)
                                .raises(JsonApiClient::Errors::NotFound, 'Resource not found')
  end
end
