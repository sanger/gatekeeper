# frozen_string_literal: true

# Standard methods for mocking the API in feature tests
module MockApiV2
  include RSpec::Mocks::ExampleMethods

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
    allow(Sequencescape::Api::V2::User).to receive(:find!).with(user_code: swipecard).and_return([mock_user])
    mock_user
  end

  # Mock a missing user for tests.
  #
  # This will mock the API to raise a NotFound error when searching for a user with the given swipecard.
  #
  # Usage:
  #
  #  ```rb
  #  MockApiV2.mock_missing_user(swipecard: 'swipecard')
  #  ```
  def self.mock_missing_user(swipecard: 'swipecard')
    allow(Sequencescape::Api::V2::User).to receive(:find!)
      .with(user_code: swipecard)
      .and_raise(JsonApiClient::Errors::NotFound, 'Resource not found')
  end

  def self.mock_lots_controller_search(lot_number, lots)
    allow(Sequencescape::Api::V2::Lot).to receive(:find).with(lot_number: lot_number).and_return(lots)
  end

  def self.mock_lots_controller_find_lot(lot)
    allow(Sequencescape::Api::V2::Lot).to receive_message_chain(:includes, :where, :first).and_return(lot)
  end
end
