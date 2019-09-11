# frozen_string_literal: true

require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test '#sorted_barcode_printers("1D Tube")' do
    assert_equal sorted_barcode_printers('1D Tube'), [
      ['1D Tube', [Hashie::Mash.new(name: 'tube_example', uuid: 'baac0dea-0000-0000-0000-000000000001')]],
      ['96 Well Plate', [Hashie::Mash.new(name: 'plate_example', uuid: 'baac0dea-0000-0000-0000-000000000000')]],
      ['384 Well Plate', [Hashie::Mash.new(name: 'tef_plate_example', uuid: 'baac0dea-0000-0000-0000-000000000002')]]
    ]
  end

  test '#sorted_barcode_printers("96 Well Plate")' do
    assert_equal sorted_barcode_printers('96 Well Plate'), [
      ['96 Well Plate', [Hashie::Mash.new(name: 'plate_example', uuid: 'baac0dea-0000-0000-0000-000000000000')]],
      ['1D Tube', [Hashie::Mash.new(name: 'tube_example', uuid: 'baac0dea-0000-0000-0000-000000000001')]],
      ['384 Well Plate', [Hashie::Mash.new(name: 'tef_plate_example', uuid: 'baac0dea-0000-0000-0000-000000000002')]]
    ]
  end

  test '#all_barcode_printers("1D Tube")' do
    assert_equal all_barcode_printers('1D Tube'), [
      ['1D Tube', [['tube_example', 'baac0dea-0000-0000-0000-000000000001']]],
      ['96 Well Plate', [['plate_example', 'baac0dea-0000-0000-0000-000000000000']]],
      ['384 Well Plate', [['tef_plate_example', 'baac0dea-0000-0000-0000-000000000002']]]
    ]
  end

  test '#all_barcode_printers("96 Well Plate")' do
    assert_equal all_barcode_printers('96 Well Plate'), [
      ['96 Well Plate', [['plate_example', 'baac0dea-0000-0000-0000-000000000000']]],
      ['1D Tube', [['tube_example', 'baac0dea-0000-0000-0000-000000000001']]],
      ['384 Well Plate', [['tef_plate_example', 'baac0dea-0000-0000-0000-000000000002']]]
    ]
  end
end
