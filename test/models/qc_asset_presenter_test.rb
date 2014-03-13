require 'test_helper'
require 'mock_api'

class QcAssetPresenterTest < ActiveSupport::TestCase

  include MockApi

  setup do
    mock_api
  end

  test "validate basic" do
    present = Presenter::QcAsset.new(api.asset.with_uuid('11111111-2222-3333-4444-500000000008'))

    api.asset.with_uuid('11111111-2222-3333-4444-500000000008').class_eval do
      include Gatekeeper::Plate::ModelExtensions
    end

    assert_equal({ 'qc_asset' => {
        'purpose' => 'Tag PCR',
        'barcode' => {
          'ean13' => '1220000036833',
          'prefix' => 'DN',
          'number' => '36'
        },
        'child_purposes' => {
          'Tag PCR-XP' => '54088cc0-a3c8-11e3-a7e1-44fb42fffecc'
        },
        'children' => [],
        'state' => 'pending',
        'handle' => {
          'with' => 'plate_creation',
          'as' => ''
        }
      }
    },present.output)
  end

  test "validate tag" do
    present = Presenter::QcAsset.new(api.asset.with_uuid('11111111-2222-3333-4444-400000000008'))

    api.asset.with_uuid('11111111-2222-3333-4444-400000000008').class_eval do
      include Gatekeeper::Plate::ModelExtensions
    end

    assert_equal({ 'qc_asset' => {
        'purpose' => 'Tag Plate',
        'barcode' => {
          'ean13' => '122000000867',
          'prefix' => 'DN',
          'number' => '8'
        },
        'child_purposes' => {
          'Tag PCR' => '53e6d3f0-a3c8-11e3-a7e1-44fb42fffecc'
        },
        'children' => ['11111111-2222-3333-4444-500000000008'],
        'state' => 'passed',
        'handle' => {
          'with' => 'plate_conversion',
          'as'   => 'target'
        }
      }
    },present.output)
  end

  test "validate reporter" do
    present = Presenter::QcAsset.new(api.asset.with_uuid('11111111-2222-3333-4444-100000000011'))

    api.asset.with_uuid('11111111-2222-3333-4444-100000000011').class_eval do
      include Gatekeeper::Plate::ModelExtensions
    end

    assert_equal({ 'qc_asset' => {
        'purpose' => 'Reporter Plate',
        'barcode' => {
          'ean13' => '122000001174',
          'prefix' => 'DN',
          'number' => '11'
        },
        'child_purposes' => {
        },
        'children' => [],
        'state' => 'available',
        'handle' => {
          'with' => 'plate_conversion',
          'as'   => 'source'
        }
      }
    },present.output)
  end

  test "validate final tube" do
    present = Presenter::QcAsset.new(api.asset.with_uuid('11111111-2222-3333-4444-700000000008'))

    api.asset.with_uuid('11111111-2222-3333-4444-700000000008').class_eval do
      include Gatekeeper::Tube::ModelExtensions
    end

    assert_equal({ 'qc_asset' => {
        'purpose' => 'Tag MX',
        'barcode' => {
          'ean13' => '3980000037732',
          'prefix' => 'NT',
          'number' => '37'
        },
        'child_purposes' => {
        },
        'children' => [],
        'state' => 'pending',
        'handle' => {
          'with' => 'completed',
          'as' => ''
        }
      }
    },present.output)
  end


end
