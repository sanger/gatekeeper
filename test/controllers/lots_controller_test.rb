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
    get :new, lot_type: 'IDT Tags'
    assert_response :success
    assert_select 'title', 'Gatekeeper'
    assert_select 'h1', 'Register IDT Tags Lot'
    assert_select 'label', 'Tag layout template'
    assert_select 'option', 'Example Tag Template'
  end

  test 'new tag from API' do
    get :new, lot_type: 'IDT Tags'
    assert_response :success
    assert_select 'title', 'Gatekeeper'
    assert_select 'h1', 'Register IDT Tags Lot'
    assert_select 'label', 'Tag layout template'
    assert_select 'option', 'Example Tag Template (API only)'
  end

  test 'new tag2' do
    get :new, lot_type: 'Tag 2 Tubes'
    assert_response :success
    assert_select 'title', 'Gatekeeper'
    assert_select 'h1', 'Register Tag 2 Tubes Lot'
    assert_select 'label', 'Tag2 layout template'
    assert_select 'option', 'Example Tag2 Template'
  end

  test 'new reporter' do
    get :new, lot_type: 'IDT Reporters'
    assert_response :success
    assert_select 'title', 'Gatekeeper'
    assert_select 'h1', 'Register IDT Reporters Lot'
    assert_select 'label', 'Plate template'
    assert_select 'option', 'Example Plate Layout'
  end

  test 'new unknown' do
    get :new, lot_type: 'News Reporters'
    assert_response :not_found
    assert_select 'title', 'Gatekeeper'
    assert_select 'h1', 'There was a problem...'
    assert_select '.alert-danger', 'Sorry! Could not register a lot. Unknown lot type &#39;News Reporters&#39;.'
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
    api.mock_user('abcdef', '11111111-2222-3333-4444-555555555555')

    api.lot_type.with_uuid('ee0b18e0-956f-11e3-8255-44fb42fffecc').lots.expect_create_with(
      received: {
        user: '11111111-2222-3333-4444-555555555555',
        lot_number: '123456789',
        template: 'ecd5cd30-956f-11e3-8255-44fb42fffecc',
        received_at: '2013-02-01'
      },
      returns: '11111111-2222-3333-4444-555555555556'
    )
    post :create,
         lot_type: 'ee0b18e0-956f-11e3-8255-44fb42fffecc',
         user_swipecard: 'abcdef',
         lot_number: '123456789',
         template: 'ecd5cd30-956f-11e3-8255-44fb42fffecc',
         received_at: '01/02/2013'

    assert_equal nil, flash[:danger]
    assert_equal 'Created lot 123456789', flash[:success]
    assert_redirected_to action: :show, id: '11111111-2222-3333-4444-555555555556'
  end

  test 'create with no user' do
    api.mock_user('123456789', '11111111-2222-3333-4444-555555555555')
    post :create,
         lot_type: 'ee0b18e0-956f-11e3-8255-44fb42fffecc',
         lot_number: '123456789',
         template: 'ecd5cd30-956f-11e3-8255-44fb42fffecc',
         received_at: '01/02/2013'
    assert_redirected_to :root
    assert_equal 'User swipecard must be provided.', flash[:danger]
  end

  test '#create with fake user' do
    api.mock_user('123456789', '11111111-2222-3333-4444-555555555555')
    post :create,
         lot_type: 'ee0b18e0-956f-11e3-8255-44fb42fffecc',
         user_swipecard: 'fake_user',
         lot_number: '123456789',
         template: 'ecd5cd30-956f-11e3-8255-44fb42fffecc',
         received_at: '01/02/2013'
    assert_redirected_to :root
    assert_equal 'User could not be found, is your swipecard registered?', flash[:danger]
  end

  # SHOW
  test 'show tag plate' do
    get :show, id: '11111111-2222-3333-4444-555555555556'
    assert_response :success

    assert_select 'h1', 'IDT Tags: 123456789'

    assert_select '#lot_number', '123456789'
    assert_select '#lot_received_at', '01/02/2013'
    assert_select '#total_plates_count', '10'
    assert_select '#created_plates_count', '2'
    assert_select '#pending_plate_7 > .plate_barcode', 'DN8'
  end

  test 'show reporter plate' do
    get :show, id: '11111111-2222-3333-4444-555555555557'
    assert_response :success

    assert_select 'h1', 'IDT Reporters: 123456790'
  end

  test 'find with one result' do
    api.search.with_uuid('689a48a0-9d46-11e3-8fed-44fb42fffecc')
       .expects(:all)
       .with(Gatekeeper::Lot, lot_number: '123456789')
       .returns([api.lot.with_uuid('11111111-2222-3333-4444-555555555556')])

    get :search, lot_number: '123456789'

    assert_redirected_to action: :show, id: '11111111-2222-3333-4444-555555555556'
  end

  test 'find with multiple results' do
    api.search.with_uuid('689a48a0-9d46-11e3-8fed-44fb42fffecc')
       .expects(:all)
       .with(Gatekeeper::Lot, lot_number: '123456789')
       .returns([api.lot.with_uuid('11111111-2222-3333-4444-555555555556'), api.lot.with_uuid('11111111-2222-3333-4444-555555555557')])

    get :search, lot_number: '123456789'

    assert_response 300
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
