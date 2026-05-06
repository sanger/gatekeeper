# frozen_string_literal: true

require 'test_helper'
require 'mock_api'

class LotsControllerTest < ActionController::TestCase
  include MockApi

  setup do
    mock_api
  end

  # NEW LOT PAGES
  test 'new tag' do
    get :new, params: { lot_type: 'IDT Tags' }
    assert_response :success
    assert_select 'title', 'Gatekeeper'
    assert_select 'h1', 'Register IDT Tags Lot'
    assert_select 'label', 'Tag layout template'
    assert_select 'option', 'Example Tag Template'
  end

  test 'new tag from API' do
    get :new, params: { lot_type: 'IDT Tags' }
    assert_response :success
    assert_select 'title', 'Gatekeeper'
    assert_select 'h1', 'Register IDT Tags Lot'
    assert_select 'label', 'Tag layout template'
    assert_select 'option', 'Example Tag Template (API only)'
  end

  test 'new unknown' do
    get :new, params: { lot_type: 'News Reporters' }
    assert_response :not_found
    assert_select 'title', 'Gatekeeper'
    assert_select 'h1', 'There was a problem...'
    assert_select '.alert-danger', "Sorry! Could not register a lot. Unknown lot type 'News Reporters'."
  end

  test 'new unspecified' do
    get :new
    assert_response :not_found
    assert_select 'title', 'Gatekeeper'
    assert_select 'h1', 'There was a problem...'
    assert_select '.alert-danger', 'Sorry! Could not register a lot. No lot type specified.'
  end

  ## CREATE
  test 'create' do
    MockApiV2.mock_user(swipecard: 'abcdef')
    mock_tag_layout_template = Sequencescape::Api::V2::TagLayoutTemplate.new(
      id: 1,
      name: 'IDT Tags',
      uuid: 'ecd5cd30-956f-11e3-8255-44fb42fffecc'
    )
    Sequencescape::Api::V2::TagLayoutTemplate.expects(:find).returns([mock_tag_layout_template])

    mock_lot = Sequencescape::Api::V2::Lot.new(
      user_uuid: '11111111-2222-3333-4444-555555555555',
      lot_number: '123456789',
      template_type: 'TagLayoutTemplate',
      template_id: 1,
      lot_type_uuid: 'ee0b18e0-956f-11e3-8255-44fb42fffecc',
      received_at: '2013-02-01'
    )
    Sequencescape::Api::V2::Lot.expects(:new).returns(mock_lot)
    mock_lot.expects(:save).returns(true).with do
      mock_lot.uuid = '11111111-2222-3333-4444-555555555556'
      true
    end
    post :create, params: {
         lot_type_uuid: 'ee0b18e0-956f-11e3-8255-44fb42fffecc',
         template_class: 'TagLayoutTemplate',
         user_swipecard: 'abcdef',
         lot_number: '123456789',
         template: 'ecd5cd30-956f-11e3-8255-44fb42fffecc',
         received_at: '01/02/2013'
    }
    assert_nil flash[:danger]
    assert_equal 'Created lot 123456789', flash[:success]
    assert_redirected_to action: :show, id: '11111111-2222-3333-4444-555555555556'
  end

  test 'create with no user' do
    post :create, params: {
         lot_type_uuid: 'ee0b18e0-956f-11e3-8255-44fb42fffecc',
         template_class: 'TagLayoutTemplate',
         lot_number: '123456789',
         template: 'ecd5cd30-956f-11e3-8255-44fb42fffecc',
         received_at: '01/02/2013'
    }
    assert_redirected_to :root
    assert_equal 'User swipecard must be provided.', flash[:danger]
  end

  test '#create with fake user' do
    MockApiV2.mock_missing_user(swipecard: 'fake_user')
    post :create, params: {
         lot_type_uuid: 'ee0b18e0-956f-11e3-8255-44fb42fffecc',
         template_class: 'TagLayoutTemplate',
         user_swipecard: 'fake_user',
         lot_number: '123456789',
         template: 'ecd5cd30-956f-11e3-8255-44fb42fffecc',
         received_at: '01/02/2013'
    }
    assert_redirected_to :root
    assert_equal 'User could not be found, is your swipecard registered?', flash[:danger]
  end

  test '#create with invalid template' do
    MockApiV2.mock_user(swipecard: 'abcdef')
    post :create, params: {
         lot_type_uuid: 'ee0b18e0-956f-11e3-8255-44fb42fffecc',
         template_class: 'BadTemplateClass',
         user_swipecard: 'abcdef',
         lot_number: '123456789',
         template: 'nonexistent-template-uuid',
         received_at: '01/02/2013'
    }
    assert_redirected_to new_lot_path
    assert_equal 'Could not find template with class BadTemplateClass or uuid nonexistent-template-uuid.', flash[:danger]
  end

  # SHOW
  test 'show tag plate' do
    mock_lot_type = Sequencescape::Api::V2::LotType.new
    mock_lot_type.qcable_name = 'Tag Plate'
    mock_lot_type.printer_type = '96 Well Plate'

    qcable_specs = [
      { state: 'created', human: 'DN1S', uuid: '11111111-2222-3333-4444-100000000001', stamp_index: nil },
      { state: 'created', human: 'DN2T', uuid: '11111111-2222-3333-4444-100000000002', stamp_index: nil },
      { state: 'qc_in_progress', human: 'DN3U', uuid: '11111111-2222-3333-4444-100000000003', stamp_index: 1 },
      { state: 'destroyed', human: 'DN4V', uuid: '11111111-2222-3333-4444-100000000004', stamp_index: 2 },
      { state: 'failed', human: 'DN5W', uuid: '11111111-2222-3333-4444-100000000005', stamp_index: 4 },
      { state: 'exhausted', human: 'DN6A', uuid: '11111111-2222-3333-4444-100000000006', stamp_index: 3 },
      { state: 'passed', human: 'DN7B', uuid: '11111111-2222-3333-4444-100000000007', stamp_index: 5 },
      { state: 'pending', human: 'DN8C', uuid: '11111111-2222-3333-4444-100000000008', stamp_index: 6 },
      { state: 'pending', human: 'DN9D', uuid: '11111111-2222-3333-4444-100000000009', stamp_index: 7 },
      { state: 'available', human: 'DN10I', uuid: '11111111-2222-3333-4444-100000000010', stamp_index: 8 }
    ]

    mock_qcables = qcable_specs.map do |spec|
      Sequencescape::Api::V2::Qcable.new(
        state: spec[:state],
        uuid: spec[:uuid],
        labware_barcode: { 'human_barcode' => spec[:human] },
        stamp_index: spec[:stamp_index]
      )
    end

    mock_lot = Sequencescape::Api::V2::Lot.new(
      uuid: '11111111-2222-3333-4444-555555555556',
      lot_number: '123456789',
      lot_type_name: 'IDT Tags',
      template_name: 'Example Tag Layout',
      received_at: '2013-02-01'
    )
    mock_lot.stubs(:lot_type).returns(mock_lot_type)
    mock_lot.stubs(:qcables).returns(mock_qcables)

    scope = mock('v2_lot_scope')
    Sequencescape::Api::V2::Lot.stubs(:includes).with(:lot_type, :qcables).returns(scope)
    scope.stubs(:where).with(uuid: '11111111-2222-3333-4444-555555555556').returns([mock_lot])

    get :show, params: { id: '11111111-2222-3333-4444-555555555556' }
    assert_response :success

    assert_select 'h1', 'IDT Tags: 123456789'

    assert_select '#lot_number', '123456789'
    assert_select '#lot_received_at', '01/02/2013'
    assert_select '#total_plates_count', '10'
    assert_select '#created_plates_count', '2'
    assert_select '#pending_plate_7 > .plate_barcode', 'DN8C'
  end

  test 'show reporter plate' do
    mock_lot_type = Sequencescape::Api::V2::LotType.new
    mock_lot_type.qcable_name = 'Reporter Plate'
    mock_lot_type.printer_type = '96 Well Plate'

    mock_qcable = Sequencescape::Api::V2::Qcable.new(
      state: 'created',
      uuid: '11111111-2222-3333-4444-200000000010',
      labware_barcode: { 'human_barcode' => 'DN11K' },
      stamp_index: nil
    )

    mock_lot = Sequencescape::Api::V2::Lot.new(
      uuid: '11111111-2222-3333-4444-555555555557',
      lot_number: '123456790',
      lot_type_name: 'IDT Reporters',
      template_name: 'Example Plate Layout',
      received_at: '2013-02-01'
    )
    mock_lot.stubs(:lot_type).returns(mock_lot_type)
    mock_lot.stubs(:qcables).returns([mock_qcable])

    scope = mock('v2_lot_scope')
    Sequencescape::Api::V2::Lot.stubs(:includes).with(:lot_type, :qcables).returns(scope)
    scope.stubs(:where).with(uuid: '11111111-2222-3333-4444-555555555557').returns([mock_lot])

    get :show, params: { id: '11111111-2222-3333-4444-555555555557' }
    assert_response :success

    assert_select 'h1', 'IDT Reporters: 123456790'
  end

  test 'find with one result' do
    Sequencescape::Api::V2::Lot.expects(:find)
                               .with(lot_number: '123456789')
                               .returns([Sequencescape::Api::V2::Lot.new(
                                 uuid: '11111111-2222-3333-4444-555555555556'
                               )])

    get :search, params: { lot_number: '123456789' }

    assert_redirected_to action: :show, id: '11111111-2222-3333-4444-555555555556'
  end

  test 'find with multiple results' do
    Sequencescape::Api::V2::Lot.expects(:find)
                               .with(lot_number: '123456789')
                               .returns([
                                          Sequencescape::Api::V2::Lot.new(
                                            uuid: '11111111-2222-3333-4444-555555555556',
                                            lot_type_name: 'IDT Tags',
                                            received_at: '2024/01/01',
                                            template_name: 'IDT Tags'
                                          ),
                                          Sequencescape::Api::V2::Lot.new(
                                            uuid: '11111111-2222-3333-4444-555555555557',
                                            lot_type_name: 'IDT Reporters',
                                            received_at: '2024/01/01',
                                            template_name: 'IDT Reporters'
                                          )
                                        ])

    get :search, params: { lot_number: '123456789' }

    assert_response :multiple_choices
    assert_select 'h1', 'Multiple lots found'
    assert_select 'h3', 'IDT Tags'
    assert_select 'h3', 'IDT Reporters'
  end

  test 'find with no parameters' do
    get :search

    assert_redirected_to :root
    assert_equal 'Please use the find lots by lot number feature to find specific lots.', flash[:danger]
  end
end
