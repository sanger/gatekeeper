# frozen_string_literal: true

require 'test_helper'
require 'mock_api'

class QcDecisionsControllerTest < ActionController::TestCase
  include MockApi

  setup do
    mock_api
    api.mock_user('abcdef', '11111111-2222-3333-4444-555555555555')
  end
end
