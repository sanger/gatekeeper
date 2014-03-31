require 'test_helper'
require 'mock_api'

class RobotTest < ActiveSupport::TestCase

  include MockApi

  setup do
    mock_api
    @robot = MockRobot.new(api.robot.with_uuid('40b07000-0000-0000-0000-000000000000'))
    @lot = api.lot.with_uuid('11111111-2222-3333-4444-555555555556')
    @plate_a = api.qcable.with_uuid('11111111-2222-3333-4444-100000000001')
    @plate_b = api.qcable.with_uuid('11111111-2222-3333-4444-100000000002')
    @plate_c = api.qcable.with_uuid('11111111-2222-3333-4444-100000000008')
    @plate_d = api.qcable.with_uuid('11111111-2222-3333-4444-200000000010')

    @plate_a.stubs(:in_lot?).with(@lot).returns(true)
    @plate_b.stubs(:in_lot?).with(@lot).returns(true)
    @plate_c.stubs(:in_lot?).with(@lot).returns(true)
    @plate_d.stubs(:in_lot?).with(@lot).returns(false)

    @plate_a.stubs(:stampable?).returns(true)
    @plate_b.stubs(:stampable?).returns(true)
    @plate_c.stubs(:stampable?).returns(false)
    @plate_d.stubs(:stampable?).returns(true)

    @plate_a.stubs(:human_barcode).returns('DN1')
    @plate_b.stubs(:human_barcode).returns('DN2')
    @plate_c.stubs(:human_barcode).returns('DN7')
    @plate_d.stubs(:human_barcode).returns('DN8')


  end

  class MockRobot
    include Gatekeeper::Robot::ValidationMethods
    include Gatekeeper::Robot::BasicMethods
    include Gatekeeper::Robot::CreationMethods

    def initialize(api)
      @api=api
    end

    def method_missing(method, *params, &block)
      @api.__send__(method,*params,&block)
    end
  end

  test "validate lot" do
    valid, message = @robot.valid_lot?('580000001806',@lot)
    assert_equal true, valid
    assert_equal 'Correct bed used.', message
  end

  test "validate invalid bed" do
    valid, message = @robot.valid_lot?('580000002810',@lot)
    assert_equal 'The lot plate should be placed on Bed 1 to begin the process.', message
    assert_equal false, valid
  end

  test "validate full setup" do
    valid, message = @robot.valid?('580000001806', @lot, {'580000002810'=>@plate_a,'580000003824'=>@plate_b})
    assert_equal 'Okay', message
    assert_equal true, valid
  end

  test "validate wrong state" do
    valid, message = @robot.valid?('580000001806', @lot, {'580000002810'=>@plate_a,'580000003824'=>@plate_c})
    assert_equal "DN7 is 'pending'; only 'created' plates may be stamped.", message
    assert_equal false, valid
  end

  test "validate wrong child" do
    valid, message = @robot.valid?('580000001806', @lot, {'580000002810'=>@plate_a,'580000003824'=>@plate_d})
    assert_equal "DN8 is not in lot 123456789", message
    assert_equal false, valid
  end

  test "validate extra beds" do
    valid, message = @robot.valid?('580000001806', @lot, {'580000002810'=>@plate_a,'580000003824'=>@plate_b,'580000003835'=>@plate_c})
    assert_equal 'Invalid beds: 580000003835', message
    assert_equal false, valid
  end

  test "validate duplicate plates detected" do
    valid, message = @robot.valid?('580000001806', @lot, {'580000002810'=>@plate_a,'580000003824'=>@plate_a})
    assert_equal false, valid
    assert_equal 'Plates can only be located on one bed. Check for duplicates', message
  end

  test "validate duplicate beds detected" do
    valid, message = @robot.valid?('580000001806', @lot, {'580000002810'=>@plate_a,'580000002810'=>@plate_b})
    assert_equal false, valid
    assert_equal 'Bed 3 should not be empty. 580000003824', message
  end

  test "beds for" do
    beds_for = @robot.beds_for({'580000002810'=>@plate_a,'580000003824'=>@plate_b})
    assert_equal [
      {:bed=>'2',:order=>1,:qcable=>'11111111-2222-3333-4444-100000000001'},
      {:bed=>'3',:order=>2,:qcable=>'11111111-2222-3333-4444-100000000002'}
    ], beds_for
  end

end
