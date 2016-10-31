require 'test_helper'
require 'mock_api'

class QcAssetsControllerTest < ActionController::TestCase

  include MockApi

  setup do
    mock_api
    api.mock_user('abcdef','11111111-2222-3333-4444-555555555555')
  end

  test "new qc" do
    get :new
    assert_response :success
  end

  test "search" do
    api.search.with_uuid('e7d2fec0-956f-11e3-8255-44fb42fffecc').
    expects(:first).
    with(barcode: '122000000867').
    returns(api.asset.with_uuid('11111111-2222-3333-4444-300000000008'))

    api.asset.with_uuid('11111111-2222-3333-4444-300000000008').class_eval do
      include Gatekeeper::Plate::ModelExtensions
      include StateExtensions
    end

    @request.headers["Accept"] = "application/json"
    get :search, {user_swipecard: 'abcdef',asset_barcode: '122000000867'}

    assert_response :success
    present = assigns['presenter']
    assert_equal '11111111-2222-3333-4444-300000000008', present.uuid
    assert_equal 'Tag Plate', present.purpose
    assert_equal([['Tag PCR','53e6d3f0-a3c8-11e3-a7e1-44fb42fffecc']], present.child_purposes)
    assert_equal [], present.children
    assert_equal 'pending', present.state
  end

  test "search not found" do
    api.search.with_uuid('e7d2fec0-956f-11e3-8255-44fb42fffecc').
    expects(:first).
    with(barcode: '122000000867').
    raises(Sequencescape::Api::ResourceNotFound,'There is an issue with the API connection to Sequencescape (["no resources found with that search criteria"])')

    api.asset.with_uuid('11111111-2222-3333-4444-300000000008').class_eval do
      include Gatekeeper::Plate::ModelExtensions
      include StateExtensions
    end

    @request.headers["Accept"] = "application/json"
    get :search, {user_swipecard: 'abcdef',asset_barcode: '122000000867'}

    assert_response 404
  end

  test "search with children" do
    api.search.with_uuid('e7d2fec0-956f-11e3-8255-44fb42fffecc').
    expects(:first).
    with(barcode: '122000000867').
    returns(api.asset.with_uuid('11111111-2222-3333-4444-400000000008'))

    api.asset.with_uuid('11111111-2222-3333-4444-400000000008').class_eval do
      include Gatekeeper::Plate::ModelExtensions
      include StateExtensions
    end

    @request.headers["Accept"] = "application/json"
    get :search, {user_swipecard: 'abcdef',asset_barcode: '122000000867'}

    assert_response :success
    present = assigns['presenter']
    assert_equal '11111111-2222-3333-4444-400000000008', present.uuid
    assert_equal 'Tag Plate', present.purpose
    assert_equal([['Tag PCR','53e6d3f0-a3c8-11e3-a7e1-44fb42fffecc']], present.child_purposes)
    assert_equal 1, present.children.size
    assert_equal '11111111-2222-3333-4444-500000000008', present.children.first.uuid
    assert_equal 'passed', present.state
  end

  test "search for tube" do
    api.search.with_uuid('e7d2fec0-956f-11e3-8255-44fb42fffecc').
    expects(:first).
    with(barcode: '3980000037732').
    returns(api.asset.with_uuid('11111111-2222-3333-4444-600000000008'))

    api.asset.with_uuid('11111111-2222-3333-4444-600000000008').class_eval do
      include Gatekeeper::Tube::ModelExtensions
    end

    @request.headers["Accept"] = "application/json"
    get :search, {user_swipecard: 'abcdef',asset_barcode: '3980000037732'}

    assert_response :success
    present = assigns['presenter']
    assert_equal '11111111-2222-3333-4444-600000000008', present.uuid
    assert_equal 'Tag Stock-MX', present.purpose
    assert_equal([['Tag MX','541b5170-a3c8-11e3-a7e1-44fb42fffecc']], present.child_purposes)
    assert_equal 1, present.children.size
    assert_equal '11111111-2222-3333-4444-700000000008', present.children.first.uuid
    assert_equal 'pending', present.state
  end

  test "create standard" do

    api.asset.with_uuid('11111111-2222-3333-4444-500000000008').class_eval do
      include Gatekeeper::Plate::ModelExtensions
      include StateExtensions
    end
    api.plate_creation.with_uuid('11111111-2222-3333-4444-330000000008').child.class_eval do
      include Gatekeeper::Plate::ModelExtensions
      include StateExtensions
    end

    api.search.with_uuid('e7d2fec0-956f-11e3-8255-44fb42fffecc').
      expects(:first).
      with(barcode: '1220000036833').
      returns(api.plate.with_uuid('11111111-2222-3333-4444-500000000008'))


    api.plate_creation.expect_create_with(
      received: {
          parent: '11111111-2222-3333-4444-500000000008',
          child_purpose: '54088cc0-a3c8-11e3-a7e1-44fb42fffecc',
          user: '11111111-2222-3333-4444-555555555555'
        },
      returns: '11111111-2222-3333-4444-330000000008'
      )
    api.transfer_template.with_uuid('8c716230-a922-11e3-926d-44fb42fffecc').expects(:create!).with(
        source: '11111111-2222-3333-4444-500000000008',
        destination: '11111111-2222-3333-4444-510000000008',
        user: '11111111-2222-3333-4444-555555555555'
    )

    api.state_change.expect_create_with(
      received: {
        user: '11111111-2222-3333-4444-555555555555',
        target: '11111111-2222-3333-4444-500000000008',
        target_state: 'passed'
      },
      returns: '55555555-6666-7777-8888-000000000004'
    )

    @request.headers["Accept"] = "application/json"
    post :create, {
      user_swipecard: 'abcdef',
      asset_barcode: '1220000036833',
      purpose: '54088cc0-a3c8-11e3-a7e1-44fb42fffecc'
    }
    assert_equal nil, flash[:danger]

    assert_redirected_to controller: :plates, action: :show, id: '11111111-2222-3333-4444-510000000008'
  end

  test "create convert tag" do

    api.asset.with_uuid('11111111-2222-3333-4444-300000000008').class_eval do
      include Gatekeeper::Plate::ModelExtensions
      include StateExtensions
    end
    api.asset.with_uuid('11111111-2222-3333-4444-100000000011').class_eval do
      include Gatekeeper::Plate::ModelExtensions
      include StateExtensions
    end
    api.plate.with_uuid('11111111-2222-3333-4444-500000000008').class_eval do
      include Gatekeeper::Plate::ModelExtensions
      include StateExtensions
    end

    api.search.with_uuid('e7d2fec0-956f-11e3-8255-44fb42fffecc').
      expects(:first).
      with(barcode: '122000001174').
      returns(api.plate.with_uuid('11111111-2222-3333-4444-100000000011'))
    api.search.with_uuid('e7d2fec0-956f-11e3-8255-44fb42fffecc').
      expects(:first).
      with(barcode: '122000000867').
      returns(api.plate.with_uuid('11111111-2222-3333-4444-300000000008'))
    api.search.with_uuid('689a48a0-9d46-11e3-8fed-44fb42fffeff').
      expects(:first).
      with(barcode: '122000000867').
      returns(api.qcable.with_uuid('11111111-2222-3333-4444-100000000008'))

    api.state_change.expect_create_with(
      received: {
        user: '11111111-2222-3333-4444-555555555555',
        target: '11111111-2222-3333-4444-300000000008',
        target_state: 'qc_in_progress',
        reason: 'Used in QC'
        },
      returns: '55555555-6666-7777-8888-000000000003')
    api.state_change.expect_create_with(
      received: {
        user: '11111111-2222-3333-4444-555555555555',
        target: '11111111-2222-3333-4444-100000000011',
        target_state: 'exhausted',
        reason: 'Used to QC'
        },
      returns: '55555555-6666-7777-8888-000000000003')


    api.plate_conversion.expect_create_with(
      received: {
          target: '11111111-2222-3333-4444-300000000008',
          purpose: '53e6d3f0-a3c8-11e3-a7e1-44fb42fffecc',
          user: '11111111-2222-3333-4444-555555555555'
        },
      returns: '11111111-2222-3333-4444-340000000008'
      )
    api.transfer_template.with_uuid('8c716230-a922-11e3-926d-44fb42fffecc').expects(:create!).with(
        source: '11111111-2222-3333-4444-100000000011',
        destination: '11111111-2222-3333-4444-300000000008',
        user: '11111111-2222-3333-4444-555555555555'
      )
    api.tag_layout_template.with_uuid('ecd5cd30-956f-11e3-8255-44fb42fffecc').expects(:create!).with(
        user: '11111111-2222-3333-4444-555555555555',
        plate: '11111111-2222-3333-4444-300000000008',
        substitutions: {}
      )

    @request.headers["Accept"] = "application/json"
    post :create, {
      user_swipecard: 'abcdef',
      asset_barcode: '122000000867',
      purpose: '53e6d3f0-a3c8-11e3-a7e1-44fb42fffecc',
      sibling: '122000001174',
      template: '8c716230-a922-11e3-926d-44fb42fffecc'
    }
    assert_equal nil, flash[:danger]

    assert_redirected_to controller: :plates, action: :show, id: '11111111-2222-3333-4444-500000000008'
  end

  test "create convert reporter" do

    api.asset.with_uuid('11111111-2222-3333-4444-300000000008').class_eval do
      include Gatekeeper::Plate::ModelExtensions
      include StateExtensions
      def state; 'available'; end
    end
    api.asset.with_uuid('11111111-2222-3333-4444-100000000011').class_eval do
      include Gatekeeper::Plate::ModelExtensions
      include StateExtensions
      def state; 'pending'; end
    end
    api.plate.with_uuid('11111111-2222-3333-4444-500000000008').class_eval do
      include Gatekeeper::Plate::ModelExtensions
      include StateExtensions
    end

    api.search.with_uuid('e7d2fec0-956f-11e3-8255-44fb42fffecc').
      expects(:first).
      with(barcode: '122000000867').
      returns(api.plate.with_uuid('11111111-2222-3333-4444-300000000008'))
    api.search.with_uuid('e7d2fec0-956f-11e3-8255-44fb42fffecc').
      expects(:first).
      with(barcode: '122000001174').
      returns(api.plate.with_uuid('11111111-2222-3333-4444-100000000011'))
    api.search.with_uuid('689a48a0-9d46-11e3-8fed-44fb42fffeff').
      expects(:first).
      with(barcode: '122000000867').
      returns(api.qcable.with_uuid('11111111-2222-3333-4444-100000000008'))

    api.state_change.expect_create_with(
      received: {
        user: '11111111-2222-3333-4444-555555555555',
        target: '11111111-2222-3333-4444-100000000011',
        target_state: 'qc_in_progress',
        reason: 'Used in QC'
        },
      returns: '55555555-6666-7777-8888-000000000003')
    api.state_change.expect_create_with(
      received: {
        user: '11111111-2222-3333-4444-555555555555',
        target: '11111111-2222-3333-4444-300000000008',
        target_state: 'exhausted',
        reason: 'Used to QC'
        },
      returns: '55555555-6666-7777-8888-000000000003')

    api.plate_conversion.expect_create_with(
      received: {
          target: '11111111-2222-3333-4444-300000000008',
          purpose: '53e6d3f0-a3c8-11e3-a7e1-44fb42fffecc',
          user: '11111111-2222-3333-4444-555555555555'
        },
      returns: '11111111-2222-3333-4444-340000000008'
      )
    api.transfer_template.with_uuid('58b72440-ab69-11e3-bb8f-44fb42fffecc').expects(:create!).with(
      source: '11111111-2222-3333-4444-100000000011',
      destination: '11111111-2222-3333-4444-300000000008',
      user: '11111111-2222-3333-4444-555555555555'
    )
    api.tag_layout_template.with_uuid('ecd5cd30-956f-11e3-8255-44fb42fffecc').expects(:create!).with(
      user: '11111111-2222-3333-4444-555555555555',
      plate: '11111111-2222-3333-4444-300000000008',
      substitutions: {}
    )

    @request.headers["Accept"] = "application/json"
    post :create, {
      user_swipecard: 'abcdef',
      asset_barcode: '122000001174',
      purpose: '53e6d3f0-a3c8-11e3-a7e1-44fb42fffecc',
      sibling: '122000000867',
      template: '58b72440-ab69-11e3-bb8f-44fb42fffecc'
    }
    assert_equal nil, flash[:danger]
    assert_redirected_to controller: :plates, action: :show, id: '11111111-2222-3333-4444-500000000008'
  end

  test "smart state detection" do

    reporter_plate = '11111111-2222-3333-4444-100000000011'
    tag_plate      = '11111111-2222-3333-4444-300000000008'
    tag_plate_bc   = '122000000867'
    reporter_plate_bc = '122000001174'

    api.asset.with_uuid('11111111-2222-3333-4444-300000000008').class_eval do
      include Gatekeeper::Plate::ModelExtensions
      include StateExtensions
    end
    api.asset.with_uuid('11111111-2222-3333-4444-100000000011').class_eval do
      include Gatekeeper::Plate::ModelExtensions
      include StateExtensions
    end
    api.plate.with_uuid('11111111-2222-3333-4444-500000000008').class_eval do
      include Gatekeeper::Plate::ModelExtensions
      include StateExtensions
    end

    api.search.with_uuid('e7d2fec0-956f-11e3-8255-44fb42fffecc').
      stubs(:first).
      with(barcode: tag_plate_bc).
      returns(api.plate.with_uuid(tag_plate))
    api.search.with_uuid('e7d2fec0-956f-11e3-8255-44fb42fffecc').
      stubs(:first).
      with(barcode: reporter_plate_bc).
      returns(api.plate.with_uuid(reporter_plate))
    api.search.with_uuid('689a48a0-9d46-11e3-8fed-44fb42fffeff').
      stubs(:first).
      with(barcode: '122000000867').
      returns(api.qcable.with_uuid('11111111-2222-3333-4444-100000000008'))
    2.times do
      api.tag_layout_template.with_uuid('ecd5cd30-956f-11e3-8255-44fb42fffecc').expects(:create!).with(
        user: '11111111-2222-3333-4444-555555555555',
        plate: '11111111-2222-3333-4444-300000000008',
        substitutions: {}
      )
    end

    [
      {
        protagonist: tag_plate,
        protagonist_bc: tag_plate_bc,
        sibling: reporter_plate,
        sibling_bc: reporter_plate_bc,
        protagonist_state: 'pending',
        sibling_state: 'available',
        success: true,
      },
      {
        protagonist: reporter_plate,
        protagonist_bc: reporter_plate_bc,
        sibling: tag_plate,
        sibling_bc: tag_plate_bc,
        protagonist_state: 'pending',
        sibling_state: 'available',
        success: true
      },
      {
        protagonist: tag_plate,
        protagonist_bc: tag_plate_bc,
        sibling: reporter_plate,
        sibling_bc: reporter_plate_bc,
        protagonist_state: 'pending',
        sibling_state: 'pending',
        success: false
      },
      {
        protagonist: tag_plate,
        protagonist_bc: tag_plate_bc,
        sibling: reporter_plate,
        sibling_bc: reporter_plate_bc,
        protagonist_state: 'available',
        sibling_state: 'available',
        success: false
      },
    ].each do |test|

      pc = mock('plate_conversion')
      pc.stubs(:target).returns(api.plate.with_uuid(tag_plate))

      api.plate_conversion.stubs(:create!).returns(pc)
      api.state_change.stubs(:create!).returns(nil)

      api.transfer_template.with_uuid('8c716230-a922-11e3-926d-44fb42fffecc').stubs(:create!)

      api.plate.with_uuid(test[:protagonist]).stubs(:state).returns(test[:protagonist_state])
      api.plate.with_uuid(test[:sibling]).stubs(:state).returns(test[:sibling_state])

      @request.headers["Accept"] = "application/json"
      post :create, {
        user_swipecard: 'abcdef',
        asset_barcode: test[:protagonist_bc],
        purpose: '53e6d3f0-a3c8-11e3-a7e1-44fb42fffecc',
        sibling: test[:sibling_bc]
      }

      if  test[:success]
        assert_response 302
      else
        presenter = assigns['presenter']
        assert_equal 'Presenter::Error', presenter.class.to_s
      end
    end

  end

  test "qa plate ignores state" do

    qa_plate = 'e4c73db0-d972-11e5-b6f0-44fb42fffe72'
    qcable_tag_plate = '11111111-2222-3333-4444-100000000008'
    tag_plate = '11111111-2222-3333-4444-300000000008'
    tag_plate_bc = '122000001867'
    qa_plate_bc = '1229000001872'

    qcable_barcode = '122000000867'

    tag_pcr_plate = '11111111-2222-3333-4444-500000000008'
    uuid_find_assets_by_barcode = 'e7d2fec0-956f-11e3-8255-44fb42fffecc'
    uuid_find_qcable_by_barcode = '689a48a0-9d46-11e3-8fed-44fb42fffeff'
    uuid_example_tag_template = 'ecd5cd30-956f-11e3-8255-44fb42fffecc'
    uuid_transfer_columns_1_12 = '8c716230-a922-11e3-926d-44fb42fffecc'
    uuid_tag_pcr_purpose = '53e6d3f0-a3c8-11e3-a7e1-44fb42fffecc'

    api.asset.with_uuid(tag_plate).class_eval do
      include Gatekeeper::Plate::ModelExtensions
      include StateExtensions
    end
    api.asset.with_uuid(qa_plate).class_eval do
      include Gatekeeper::Plate::ModelExtensions
      include StateExtensions
    end
    api.plate.with_uuid(tag_pcr_plate).class_eval do
      include Gatekeeper::Plate::ModelExtensions
      include StateExtensions
    end

    api.search.with_uuid(uuid_find_assets_by_barcode).
      stubs(:first).
      with(barcode: tag_plate_bc).
      returns(api.plate.with_uuid(tag_plate))
    api.search.with_uuid(uuid_find_assets_by_barcode).
      stubs(:first).
      with(barcode: qa_plate_bc).
      returns(api.plate.with_uuid(qa_plate))
    api.search.with_uuid(uuid_find_qcable_by_barcode).
      stubs(:first).
      with(barcode: qcable_barcode).
      returns(api.qcable.with_uuid(qcable_tag_plate))

    api.tag_layout_template.with_uuid(uuid_example_tag_template).
      stubs(:create!)

    [
      {
        protagonist: tag_plate,
        protagonist_bc: tag_plate_bc,
        sibling: qa_plate,
        sibling_bc: qa_plate_bc,
        protagonist_state: 'pending',
        sibling_state: 'available',
        success: false,
      },
      {
        protagonist: qa_plate,
        protagonist_bc: qa_plate_bc,
        sibling: tag_plate,
        sibling_bc: tag_plate_bc,
        protagonist_state: 'pending',
        sibling_state: 'available',
        success: true
      },
      {
        protagonist: qa_plate,
        protagonist_bc: qa_plate_bc,
        sibling: tag_plate,
        sibling_bc: tag_plate_bc,
        protagonist_state: 'passed',
        sibling_state: 'available',
        success: true
      },
      {
        protagonist: qa_plate,
        protagonist_bc: qa_plate_bc,
        sibling: tag_plate,
        sibling_bc: tag_plate_bc,
        protagonist_state: 'failed',
        sibling_state: 'available',
        success: true
      },
    ].each do |test|

      pc = mock('qa_plate_conversion')
      pc.stubs(:target).returns(api.plate.with_uuid(tag_plate))

      api.plate_conversion.stubs(:create!).returns(pc)
      api.state_change.stubs(:create!).returns(nil)

      api.transfer_template.with_uuid(uuid_transfer_columns_1_12).stubs(:create!)

      api.plate.with_uuid(test[:protagonist]).stubs(:state).returns(test[:protagonist_state])
      api.plate.with_uuid(test[:sibling]).stubs(:state).returns(test[:sibling_state])

      @request.headers["Accept"] = "application/json"
      post :create, {
        user_swipecard: 'abcdef',
        asset_barcode: test[:protagonist_bc],
        purpose: uuid_tag_pcr_purpose,
        sibling: test[:sibling_bc]
      }

      if  test[:success]
        assert_response 302
      else
        presenter = assigns['presenter']
        assert_equal 'Presenter::Error', presenter.class.to_s
      end
    end
  end

  test "create convert tag2" do

    tag_plate = '11111111-2222-3333-4444-300000000008'
    reporter_plate = '11111111-2222-3333-4444-100000000011'
    tag2_tube_1 = '11111111-2222-3333-4444-800000000008'
    tag2_tube_2 = '11111111-2222-3333-4444-900000000008'
    tag2_qc_1 = '11111111-2222-3333-4444-200000000011'
    tag2_qc_2 = '11111111-2222-3333-4444-200000000012'
    find_assets_by_barcode = 'e7d2fec0-956f-11e3-8255-44fb42fffecc'
    user = '11111111-2222-3333-4444-555555555555'
    qcable_tag_plate = '11111111-2222-3333-4444-100000000007'
    flip_plate_template = '58b72440-ab69-11e3-bb8f-44fb42fffecc'
    child_purpose = '53e6d3f0-a3c8-11e3-a7e1-44fb42fffecc'
    find_qcables_by_barcode = '689a48a0-9d46-11e3-8fed-44fb42fffeff'

    api.asset.with_uuid(tag_plate).class_eval do
      include Gatekeeper::Plate::ModelExtensions
      include StateExtensions
      def state; 'available'; end
    end
    api.asset.with_uuid(reporter_plate).class_eval do
      include Gatekeeper::Plate::ModelExtensions
      include StateExtensions
      def state; 'available'; end
    end
    api.asset.with_uuid(tag2_tube_1).class_eval do
      include Gatekeeper::Tube::ModelExtensions
      include StateExtensions
    end
    api.asset.with_uuid(tag2_tube_2).class_eval do
      include Gatekeeper::Tube::ModelExtensions
      include StateExtensions
    end
    api.qcable.with_uuid(tag2_qc_1).class_eval do
      include Gatekeeper::Tube::ModelExtensions
      include StateExtensions
    end
    api.qcable.with_uuid(tag2_qc_2).class_eval do
      include Gatekeeper::Tube::ModelExtensions
      include StateExtensions
    end
    api.plate.with_uuid('11111111-2222-3333-4444-500000000008').class_eval do
      include Gatekeeper::Plate::ModelExtensions
      include StateExtensions
    end

    # Looks up the tag plate
    api.search.with_uuid(find_assets_by_barcode).
      expects(:first).
      with(barcode: '122000000867').
      returns(api.plate.with_uuid(tag_plate))

    # Looks up the reporter_plate
    api.search.with_uuid(find_assets_by_barcode).
      expects(:first).
      with(barcode: '122000001174').
      returns(api.plate.with_uuid(reporter_plate))

    # Looks up the qcables (in one go)
    api.search.with_uuid(find_qcables_by_barcode).
      expects(:all).
      with(Gatekeeper::Qcable, barcode: ['3980000037732','3980000037733']).
      returns([api.qcable.with_uuid(tag2_qc_1),api.qcable.with_uuid(tag2_qc_2)])

    # Looks up the tag plate again?
    api.search.with_uuid(find_qcables_by_barcode).
      stubs(:first).
      with(barcode: '122000000867').
      returns(api.qcable.with_uuid(qcable_tag_plate))

    # Would be nice to get rid of this
    api.search.with_uuid(find_assets_by_barcode).
      expects(:first).
      with(barcode: '3980000037732').
      returns(api.tube.with_uuid(tag2_tube_1))

    api.state_change.expect_create_with(
      received: {
        user: user,
        target: reporter_plate,
        target_state: 'exhausted',
        reason: 'Used to QC'
        },
      returns: '55555555-6666-7777-8888-000000000003')
    api.state_change.expect_create_with(
      received: {
        user: user,
        target: tag_plate,
        target_state: 'exhausted',
        reason: 'Used to QC'
        },
      returns: '55555555-6666-7777-8888-000000000003')

    api.plate_conversion.expect_create_with(
      received: {
          target: tag_plate,
          purpose: child_purpose,
          user: user
        },
      returns: '11111111-2222-3333-4444-340000000008'
      )

    # Transfer only the relevant wells
    api.bulk_transfer.expects(:create!).with(
      source: reporter_plate,
      user: user,
      well_transfers: %w(A1 A3 D1 D3).map do |well|
        {
          "source_uuid" => reporter_plate,
          "source_location" => well,
          "destination_uuid" => tag_plate,
          "destination_location" => well
        }
      end
    )
    api.tag_layout_template.with_uuid('ecd5cd30-956f-11e3-8255-44fb42fffecc').expects(:create!).with(
      user: user,
      plate: tag_plate,
      substitutions: {}
    )
    api.tag2_layout_template.with_uuid('ecd5cd30-956f-11e3-8255-44fb42fffedd').expects(:create!).with(
      user: user,
      plate: tag_plate,
      source: tag2_tube_1,
      target_well_locations: ["A1", "A3"]
    )
    api.tag2_layout_template.with_uuid('ecd5cd30-956f-11e3-8255-44fb42fffedd').expects(:create!).with(
      user: user,
      plate: tag_plate,
      source: tag2_tube_2,
      target_well_locations: ["D1", "D3"]
    )

    @request.headers["Accept"] = "application/json"

    post :create, {
      user_swipecard: 'abcdef',
      asset_barcode: '3980000037732',
      tag2_tube: {
        "1" => { barcode: "3980000037732", target_well_locations: {"0" => "A1", "1" => "A3"}},
        "2" => {},
        "3" => {},
        "4" => {barcode: "3980000037733",target_well_locations: {"0" => "D1", "1" => "D3"}},
        "5" => {},
        "6" => {},
        "7" => {},
        "8" => {},
        "9" => {},
        "10" => {},
        "11" => {},
        "12" => {},
        "13" => {},
        "14" => {},
        "15" => {},
        "16" => {}
        },
      purpose: child_purpose,
      sibling: '122000000867',
      sibling2: '122000001174',
      template: flip_plate_template
    }

    assert_equal nil, flash[:danger]
    assert_redirected_to controller: :plates, action: :show, id: '11111111-2222-3333-4444-500000000008'
  end

end
