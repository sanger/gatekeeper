# frozen_string_literal: true

require 'test_helper'
require 'mock_api'

class StampsControllerTest < ActionController::TestCase
  include MockApi

  test 'new' do
    get :new
    assert_response :success
    assert_template :new
  end

  setup do
    mock_api
    @robot = api.robot.with_uuid('40b07000-0000-0000-0000-000000000000')
    @lot = Sequencescape::Api::V2::Lot.new(uuid: '11111111-2222-3333-4444-555555555556')
    @lot.stubs(:lot_number).returns('123456789')
    @plate_a = api.qcable.with_uuid('11111111-2222-3333-4444-100000000001')
    @plate_b = api.qcable.with_uuid('11111111-2222-3333-4444-100000000002')
    @plate_c = api.qcable.with_uuid('11111111-2222-3333-4444-100000000008')
    api.mock_user('123456789', '11111111-2222-3333-4444-555555555555')
  end

  test 'validate lot' do
    Sequencescape::Api::V2::Lot.expects(:where).with(lot_number: '123456789').returns(
      mock('v2_lot_scope').tap { |s| s.stubs(:all).returns([@lot]) }
    )

    @robot.expects(:valid_lot?)
          .with('58000000180', @lot)
          .returns([true, 'Okay'])
    @request.headers['Accept'] = 'application/json'
    post :validation, params: {
         user_swipecard: '123456789',
         robot_barcode: '488000000178',
         robot_uuid: '40b07000-0000-0000-0000-000000000000',
         tip_lot: '12345678',
         validate: 'lot',
         lot_bed: '58000000180',
         lot_plate: '123456789'
    }
    assert_response :success
    assert_equal @robot, assigns['robot']
    assert_equal @lot, assigns['lot']
    assert_equal({ 'validation' => { 'status' => true, 'messages' => ['Okay'] } }.to_json, assigns['validator'].to_json)
  end

  test 'validate lot when false' do
    Sequencescape::Api::V2::Lot.expects(:where).with(lot_number: '123456789').returns(
      mock('v2_lot_scope').tap { |s| s.stubs(:all).returns([@lot]) }
    )

    @robot.expects(:valid_lot?)
          .with('58000000180', @lot)
          .returns([false, 'Not okay'])
    @request.headers['Accept'] = 'application/json'
    post :validation, params: {
         user_swipecard: '123456789',
         robot_barcode: '488000000178',
         robot_uuid: '40b07000-0000-0000-0000-000000000000',
         tip_lot: '12345678',
         validate: 'lot',
         lot_bed: '58000000180',
         lot_plate: '123456789'
    }
    assert_response :success
    assert_equal @robot, assigns['robot']
    assert_equal @lot, assigns['lot']
    assert_equal({ 'validation' => { 'status' => false, 'messages' => ['Not okay'] } }.to_json, assigns['validator'].to_json)
  end

  test 'validate invalid lot' do
    @robot.expects(:valid_lot?)
          .with('58000000180', nil)
          .returns([true, 'Okay'])

    Sequencescape::Api::V2::Lot.expects(:where).with(lot_number: 'not_a_lot').returns(
      mock('v2_lot_scope').tap { |s| s.stubs(:all).returns([]) }
    )
    @request.headers['Accept'] = 'application/json'
    post :validation, params: {
         user_swipecard: '123456789',
         robot_barcode: '488000000178',
         robot_uuid: '40b07000-0000-0000-0000-000000000000',
         tip_lot: '12345678',
         validate: 'lot',
         lot_bed: '58000000180',
         lot_plate: 'not_a_lot'
    }
    assert_response :success
    assert_equal @robot, assigns['robot']
    assert_equal({ 'validation' => { 'status' => false, 'messages' => ["Could not find a lot with the lot number 'not_a_lot'", 'Okay'] } }.to_json, assigns['validator'].to_json)
  end

  test 'validate full setup' do
    Sequencescape::Api::V2::Lot.expects(:where).with(lot_number: '123456789').returns(
      mock('v2_lot_scope').tap { |s| s.stubs(:all).returns([@lot]) }
    )

    api.search.with_uuid('689a48a0-9d46-11e3-8fed-44fb42fffeff')
       .expects(:all)
       .with(Gatekeeper::Qcable, barcode: %w[DN1S DN2T])
       .returns([@plate_a, @plate_b])

    @robot.expects(:valid?)
          .with('58000000180', @lot,
                { '58000000281' => @plate_a,
                  '58000000382' => @plate_b })
          .returns([true, 'Okay'])
    @request.headers['Accept'] = 'application/json'
    post :validation, params: {
         user_swipecard: '123456789',
         robot_barcode: '488000000178',
         robot_uuid: '40b07000-0000-0000-0000-000000000000',
         tip_lot: '12345678',
         validate: 'full',
         lot_bed: '58000000180',
         lot_plate: '123456789',
         beds: {
           '58000000281' => 'DN1S',
           '58000000382' => 'DN2T'
         }
    }
    assert_response :success
    assert_equal @robot, assigns['robot']
    assert_equal({ 'validation' => { 'status' => true, 'messages' => ['Okay'] } }.to_json, assigns['validator'].to_json)
  end

  test 'validate full invalid' do
    Sequencescape::Api::V2::Lot.expects(:where).with(lot_number: '123456789').returns(
      mock('v2_lot_scope').tap { |s| s.stubs(:all).returns([@lot]) }
    )

    api.search.with_uuid('689a48a0-9d46-11e3-8fed-44fb42fffeff')
       .expects(:all)
       .with(Gatekeeper::Qcable, barcode: %w[DN1S DN8C])
       .returns([@plate_a, @plate_c])

    @robot.expects(:valid?)
          .with('58000000180', @lot,
                { '58000000281' => @plate_a,
                  '58000000382' => @plate_c })
          .returns([false, 'Not okay'])

    @request.headers['Accept'] = 'application/json'
    post :validation, params: {
         user_swipecard: '123456789',
         robot_barcode: '488000000178',
         robot_uuid: '40b07000-0000-0000-0000-000000000000',
         tip_lot: '12345678',
         validate: 'full',
         lot_bed: '58000000180',
         lot_plate: '123456789',
         beds: {
           '58000000281' => 'DN1S',
           '58000000382' => 'DN8C'
         }
    }
    assert_response :success
    assert_equal @robot, assigns['robot']
    assert_equal({ 'validation' => { 'status' => false, 'messages' => ['Not okay'] } }.to_json, assigns['validator'].to_json)
  end

  test 'validate full multiple barcodes' do
    Sequencescape::Api::V2::Lot.expects(:where).with(lot_number: '123456789').returns(
      mock('v2_lot_scope').tap { |s| s.stubs(:all).returns([@lot]) }
    )

    api.search.with_uuid('689a48a0-9d46-11e3-8fed-44fb42fffeff')
       .expects(:all)
       .with(Gatekeeper::Qcable, barcode: ['DN1S'])
       .returns([@plate_a])

    @request.headers['Accept'] = 'application/json'
    post :validation, params: {
         user_swipecard: '123456789',
         robot_barcode: '488000000178',
         robot_uuid: '40b07000-0000-0000-0000-000000000000',
         tip_lot: '12345678',
         validate: 'full',
         lot_bed: '58000000180',
         lot_plate: '123456789',
         beds: {
           '58000000281' => 'DN1S',
           '58000000382' => 'DN1S'
         }
    }
    assert_response :success
    assert_equal @robot, assigns['robot']
    assert_equal({ 'validation' => { 'status' => false, 'messages' => ['Plates can only be on one bed'] } }.to_json, assigns['validator'].to_json)
  end

  test 'validate multiple lots' do
    @robot.expects(:valid_lot?)
          .with('58000000180', @lot)
          .returns([true, 'Okay'])

    Sequencescape::Api::V2::Lot.expects(:where).with(lot_number: '123456789').returns(
      mock('v2_lot_scope').tap { |s| s.stubs(:all).returns([@lot, @lot]) }
    )

    @request.headers['Accept'] = 'application/json'
    post :validation, params: {
         user_swipecard: '123456789',
         robot_barcode: '488000000178',
         robot_uuid: '40b07000-0000-0000-0000-000000000000',
         tip_lot: '12345678',
         validate: 'lot',
         lot_bed: '58000000180',
         lot_plate: '123456789'
    }
    assert_response :success
    assert_equal({ 'validation' => {
      'status' => false,
      'messages' => ['Multiple lots with lot number 123456789. This is currently unsupported.', 'Okay']
    } }.to_json, assigns['validator'].to_json)
  end

  test 'create!' do
    api.mock_user('abcdef', '11111111-2222-3333-4444-555555555555')

    Sequencescape::Api::V2::Lot.expects(:where).with(lot_number: '123456789').returns(
      mock('v2_lot_scope').tap { |s| s.stubs(:all).returns([@lot]) }
    )

    api.search.with_uuid('689a48a0-9d46-11e3-8fed-44fb42fffeff')
       .expects(:all)
       .with(Gatekeeper::Qcable, barcode: %w[DN1S DN2T])
       .returns([@plate_a, @plate_b])

    @robot.expects(:valid?)
          .with('58000000180', @lot,
                { '58000000281' => @plate_a, '58000000382' => @plate_b })
          .returns([true, 'Okay'])

    @robot.expects(:beds_for).with(
      { '58000000281' => @plate_a,
        '58000000382' => @plate_b }
    )
          .returns([
                     { bed: '2', order: 1, qcable: '11111111-2222-3333-4444-100000000001' },
                     { bed: '3', order: 2, qcable: '11111111-2222-3333-4444-100000000002' }
                   ])

    @request.headers['Accept'] = 'application/json'

    api.stamp.expect_create_with(
      received: {
        user: '11111111-2222-3333-4444-555555555555',
        tip_lot: '12345678',
        lot: '11111111-2222-3333-4444-555555555556',
        robot: '40b07000-0000-0000-0000-000000000000',
        stamp_details: [
          { bed: '2', order: 1, qcable: '11111111-2222-3333-4444-100000000001' },
          { bed: '3', order: 2, qcable: '11111111-2222-3333-4444-100000000002' }
        ]
      },
      returns: '10204050-0000-0000-0000-000000000000'
    )

    post :create, params: {
         user_swipecard: 'abcdef',
         robot_barcode: '488000000178',
         robot_uuid: '40b07000-0000-0000-0000-000000000000',
         tip_lot: '12345678',
         validate: 'full',
         lot_bed: '58000000180',
         lot_plate: '123456789',
         beds: {
           '58000000281' => 'DN1S',
           '58000000382' => 'DN2T'
         }
    }
    assert_redirected_to lot_url(@lot.uuid)
    assert_equal 'Stamp completed!', flash[:success]
  end

  test 'create! with repeat' do
    api.mock_user('abcdef', '11111111-2222-3333-4444-555555555555')

    Sequencescape::Api::V2::Lot.expects(:where).with(lot_number: '123456789').returns(
      mock('v2_lot_scope').tap { |s| s.stubs(:all).returns([@lot]) }
    )

    api.search.with_uuid('689a48a0-9d46-11e3-8fed-44fb42fffeff')
       .expects(:all)
       .with(Gatekeeper::Qcable, barcode: %w[DN1S DN2T])
       .returns([@plate_a, @plate_b])

    @robot.expects(:valid?)
          .with('58000000180', @lot,
                { '58000000281' => @plate_a,
                  '58000000382' => @plate_b })
          .returns([true, 'Okay'])

    @robot.expects(:beds_for).with(
      { '58000000281' => @plate_a,
        '58000000382' => @plate_b }
    )
          .returns([
                     { bed: '2', order: 1, qcable: '11111111-2222-3333-4444-100000000001' },
                     { bed: '3', order: 2, qcable: '11111111-2222-3333-4444-100000000002' }
                   ])
    @request.headers['Accept'] = 'application/json'

    api.stamp.expect_create_with(
      received: {
        user: '11111111-2222-3333-4444-555555555555',
        tip_lot: '12345678',
        lot: '11111111-2222-3333-4444-555555555556',
        robot: '40b07000-0000-0000-0000-000000000000',
        stamp_details: [
          { bed: '2', order: 1, qcable: '11111111-2222-3333-4444-100000000001' },
          { bed: '3', order: 2, qcable: '11111111-2222-3333-4444-100000000002' }
        ]
      },
      returns: '10204050-0000-0000-0000-000000000000'
    )

    post :create, params: {
         user_swipecard: 'abcdef',
         robot_barcode: '488000000178',
         robot_uuid: '40b07000-0000-0000-0000-000000000000',
         tip_lot: '12345678',
         validate: 'full',
         lot_bed: '58000000180',
         lot_plate: '123456789',
         beds: {
           '58000000281' => 'DN1S',
           '58000000382' => 'DN2T'
         },
         repeat: 'repeat'
    }
    assert_redirected_to(
      controller: :stamps,
      action: :new,
      robot_barcode: '488000000178',
      tip_lot: '12345678',
      lot_bed: '58000000180',
      lot_plate: '123456789'
    )
    assert_equal 'Stamp completed!', flash[:success]
  end
end
