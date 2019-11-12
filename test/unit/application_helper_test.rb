# frozen_string_literal: true

require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  setup do
    @helper = self
  end

  test 'A number position in a plate should represent a string location' do
    testing = [
      { index_pos: 0, dim_x: 12, dim_y: 8, result: 'A1' },
      { index_pos: 1, dim_x: 12, dim_y: 8, result: 'B1' },
      { index_pos: 8, dim_x: 12, dim_y: 8, result: 'A2' },
      { index_pos: 16, dim_x: 12, dim_y: 8, result: 'A3' },
      { index_pos: 31, dim_x: 12, dim_y: 8, result: 'H4' },
      { index_pos: 9, dim_x: 12, dim_y: 8, result: 'B2' },
      { index_pos: 7, dim_x: 12, dim_y: 8, result: 'H1' },
      { index_pos: 95, dim_x: 12, dim_y: 8, result: 'H12' },
      { index_pos: 140, dim_x: 12, dim_y: 16, result: 'M9' }
    ]
    testing.each do |r|
      assert_equal r[:result], well_location_for(r[:index_pos], r[:dim_x], r[:dim_y])
    end
  end
  test 'A number position out of range in a plate should throw an exception' do
    testing = [
      { index_pos: 96, dim_x: 12, dim_y: 8, result: nil },
      { index_pos: -1, dim_x: 12, dim_y: 8, result: nil },
      { index_pos: -120, dim_x: 12, dim_y: 8, result: nil },
      { index_pos: 140, dim_x: 12, dim_y: 8, result: nil }
    ]
    testing.each do |r|
      assert_raises (RangeError) { well_location_for(r[:index_pos], r[:dim_x], r[:dim_y]) }
    end
  end
end
