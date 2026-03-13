# frozen_string_literal: true

require 'test_helper'
require 'mock_api'

class Presenter::QcableTest < ActiveSupport::TestCase
  include MockApi

  setup do
    mock_api
    @qcable_v1 = api.qcable.find('11111111-2222-3333-4444-100000000001')
    @presenter = Presenter::Qcable.new(@qcable_v1)
  end

  test '#human_readable with V1/Mock style barcodes (machine)' do
    assert_equal 'DN1S', @presenter.human_readable
  end

  test '#human_readable with V1/Mock style barcodes (prefix + number fallback)' do
    # Create a qcable mock that only has prefix and number
    bc = mock('barcode')
    bc.stubs(:respond_to?).with(:machine).returns(false)
    bc.stubs(:respond_to?).with(:prefix).returns(true)
    bc.stubs(:respond_to?).with(:number).returns(true)
    bc.stubs(:prefix).returns('DN')
    bc.stubs(:number).returns('1')

    mock_qcable = mock('qcable')
    mock_qcable.stubs(:respond_to?).with(:labware_barcode).returns(false)
    mock_qcable.stubs(:respond_to?).with(:barcode).returns(true)
    mock_qcable.stubs(:barcode).returns(bc)

    presenter = Presenter::Qcable.new(mock_qcable)
    assert_equal 'DN1', presenter.human_readable
  end

  test '#human_readable with V1/Mock style barcodes (hash)' do
    mock_qcable = mock('qcable')
    mock_qcable.stubs(:respond_to?).with(:labware_barcode).returns(false)
    mock_qcable.stubs(:respond_to?).with(:barcode).returns(true)
    mock_qcable.stubs(:barcode).returns({ 'machine' => 'DN7B' })

    presenter = Presenter::Qcable.new(mock_qcable)
    assert_equal 'DN7B', presenter.human_readable
  end

  test '#human_readable with V1/Mock style barcodes (hash prefix + number)' do
    mock_qcable = mock('qcable')
    mock_qcable.stubs(:respond_to?).with(:labware_barcode).returns(false)
    mock_qcable.stubs(:respond_to?).with(:barcode).returns(true)
    mock_qcable.stubs(:barcode).returns({ 'prefix' => 'DN', 'number' => '42' })

    presenter = Presenter::Qcable.new(mock_qcable)
    assert_equal 'DN42', presenter.human_readable
  end

  test '#human_readable with V2 style barcodes' do
    mock_qcable = mock('qcable')
    mock_qcable.stubs(:respond_to?).with(:labware_barcode).returns(true)
    mock_qcable.stubs(:labware_barcode).returns({ 'human_barcode' => 'ABC456' })

    presenter = Presenter::Qcable.new(mock_qcable)
    assert_equal 'ABC456', presenter.human_readable
  end

  test '#index' do
    assert_equal '-', @presenter.index # DN1S lamp_index is nil
  end

  test '#index with value' do
    mock_qcable = mock('qcable')
    mock_qcable.stubs(:stamp_index).returns(5)
    presenter = Presenter::Qcable.new(mock_qcable)
    assert_equal 6, presenter.index
  end

  test '#barcode' do
    assert_equal 'DN1S', @presenter.barcode
  end

  test '#uuid' do
    assert_equal '11111111-2222-3333-4444-100000000001', @presenter.uuid
  end
end
