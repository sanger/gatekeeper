# frozen_string_literal: true

# Standard methods for mocking the v1 API in feature tests
module MockApiV1
  include RSpec::Mocks::ExampleMethods

  def self.mock_api_v1
    api = instance_double('Sequencescape::Api')
    allow(Sequencescape::Api).to receive(:new).and_return(api)
  end
end
