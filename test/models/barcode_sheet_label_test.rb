# frozen_string_literal: true

require 'test_helper'
require 'mock_api'
require_relative '../support/pmb_support'

class BarcodeSheet::LabelTest < ActiveSupport::TestCase
  include MockApi

  setup do
    @label = BarcodeSheet::Label.new(barcode: 'DN1S', prefix: 'DN', number: '1', lot: 'lot_number', template: 'tag_set')
    @legacy_label = BarcodeSheet::Label.new(barcode: 'DN1S', prefix: 'DN', number: '1', study: 'lot_number:tag_set')
    # We might fail if the test runs at midnight, but timecop (or stubbing time ourselves) feels like overkill
    @date = Time.zone.today.strftime('%d-%b-%Y')
  end

  test '#plate' do
    expected_labels = {
      main_label: {
        top_left: @date,
        bottom_left: 'DN1S',
        top_right: 'DN1S',
        bottom_right: 'lot_number:tag_set',
        barcode: 'DN1S'
      }
    }
    assert_equal @label.plate, expected_labels
    assert_equal @legacy_label.plate, expected_labels
  end

  test '#tube' do
    expected_labels = {
      main_label: {
        top_line: 'lot_number:tag_set',
        middle_line: '1',
        bottom_line: @date,
        round_label_top_line: 'DN',
        round_label_bottom_line: '1',
        barcode: 'DN1S'
      }
    }
    assert_equal @label.tube, expected_labels
    assert_equal @legacy_label.tube, expected_labels
  end

  test '#plate_double' do
    expected_labels = {
      main_label: {
        left_text: 'DN1S',
        right_text: @date,
        barcode: 'DN1S'
      },
      extra_label: {
        left_text: 'lot_number:tag_set'
      }
    }
    assert_equal @label.plate_double, expected_labels
    assert_equal @legacy_label.plate_double, expected_labels
  end
end
