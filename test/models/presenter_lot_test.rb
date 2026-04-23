# frozen_string_literal: true

require 'test_helper'

class Presenter::LotTest < ActiveSupport::TestCase
  setup do
    mock_lot_type = Sequencescape::Api::V2::LotType.new
    mock_lot_type.qcable_name = 'Tag Plate'
    mock_lot_type.printer_type = '96 Well Plate'

    mock_qcables = (1..10).map do |i|
      Sequencescape::Api::V2::Qcable.new(
        uuid: "11111111-2222-3333-4444-10000000000#{i}",
        labware_barcode: { 'human_barcode' => "DN#{i}S" },
        state: 'created',
        stamp_index: nil
      )
    end

    @lot_v2 = Sequencescape::Api::V2::Lot.new(
      uuid: '11111111-2222-3333-4444-555555555556',
      lot_number: '123456789',
      lot_type_name: 'IDT Tags',
      template_name: 'Example Tag Layout',
      received_at: '2013-02-01'
    )
    @lot_v2.stubs(:lot_type).returns(mock_lot_type)
    @lot_v2.stubs(:qcables).returns(mock_qcables)

    @presenter = Presenter::Lot.new(@lot_v2)
  end

  test '#prefix with V2 style barcodes' do
    assert_equal 'DN', @presenter.prefix
  end

  test '#prefix with empty qcables' do
    mock_lot = mock('lot')
    mock_lot.stubs(:qcables).returns([])
    presenter = Presenter::Lot.new(mock_lot)
    assert_equal '', presenter.prefix
  end

  test '#prefix with no recognizable barcode' do
    bad_qcable = mock('qcable')
    bad_qcable.stubs(:respond_to?).returns(false)

    mock_lot = mock('lot')
    mock_lot.stubs(:qcables).returns([bad_qcable])

    presenter = Presenter::Lot.new(mock_lot)
    assert_equal '', presenter.prefix
  end

  test '#received_at' do
    assert_equal '01/02/2013', @presenter.received_at
  end

  test '#total_plates' do
    assert_equal 10, @presenter.total_plates
  end

  test '#child_type' do
    assert_equal 'Tag Plate', @presenter.child_type
  end

  test '#printer_type' do
    assert_equal '96 Well Plate', @presenter.printer_type
  end
end
