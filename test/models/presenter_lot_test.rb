# frozen_string_literal: true

require 'test_helper'
require 'mock_api'

class Presenter::LotTest < ActiveSupport::TestCase
  include MockApi

  setup do
    mock_api
    @lot_v2 = api.lot.find('11111111-2222-3333-4444-555555555556')
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
