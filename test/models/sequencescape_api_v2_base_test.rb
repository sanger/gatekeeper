# frozen_string_literal: true

require 'test_helper'

class SequencescapeApiV2BaseTest < ActiveSupport::TestCase
  test 'find! returns records when find is not empty' do
    record = mock('record')
    Sequencescape::Api::V2::Base.stubs(:find).with({ id: '123' }).returns([record])

    result = Sequencescape::Api::V2::Base.find!(id: '123')

    assert_equal [record], result
  end

  test 'find! raises not found when find is empty' do
    Sequencescape::Api::V2::Base.stubs(:find).with({ id: 'missing' }).returns([])

    error = assert_raises(JsonApiClient::Errors::NotFound) do
      Sequencescape::Api::V2::Base.find!(id: 'missing')
    end

    assert_equal 'Resource not found', error.message
  end
end
