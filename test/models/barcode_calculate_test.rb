# frozen_string_literal: true

require 'test_helper'
require './lib/barcode'

class BarcodeCalculateTest < ActiveSupport::TestCase
  test 'validate calculation' do
    # Barcode generation is weird.
    # The main issue being that any prefixes of less than CS
    # seem to have a leading zero in the prefix, so we end up with
    # what appears to be a 12 digit ean13. This is what the scanners
    # read back, so is probably 'correct,' just unexpected.
    assert_equal 580000001806, Barcode.calculate_barcode('BD', 1)
    assert_equal 1220000001831, Barcode.calculate_barcode('DN', 1)
  end

  test 'validate split' do
    # Barcode generation is weird.
    # The main issue being that any prefixes of less than CS
    # seem to have a leading zero in the prefix, so we end up with
    # what appears to be a 12 digit ean13. This is what the scanners
    # read back, so is probably 'correct,' just unexpected.
    assert_equal 1, Barcode.number_to_human('580000001806')
    assert_equal 1, Barcode.number_to_human('1220000001831')
  end
end
