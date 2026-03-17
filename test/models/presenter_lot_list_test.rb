# frozen_string_literal: true

require 'test_helper'

class Presenter::LotListTest < ActiveSupport::TestCase
  test 'initialise and each_lot' do
    lot1 = mock('lot1')
    lot2 = mock('lot2')
    # We need lot1/lot2 to respond to things used in Presenter::Lot.new
    [lot1, lot2].each do |l|
      l.stubs(:uuid).returns('u')
      l.stubs(:lot_number).returns('n')
      l.stubs(:lot_type_name).returns('t')
      l.stubs(:template_name).returns('tpl')
      l.stubs(:received_at).returns(Time.zone.today)
    end

    list = Presenter::LotList.new('batch1', [lot1, lot2])
    assert_equal 'batch1', list.batch_id
    assert_equal 2, list.lots.size

    count = 0
    list.each_lot do |presenter|
      assert_kind_of Presenter::Lot, presenter
      count += 1
    end
    assert_equal 2, count
  end
end
