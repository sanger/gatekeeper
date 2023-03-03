# frozen_string_literal: true

require 'test_helper'
require 'mock_api'
require 'minitest/autorun'

class CreateIDTTagPlateTest < ActionDispatch::IntegrationTest
  include MockApi
  attr_reader :test_file, :plate_uploader

  setup do
    mock_api
    api.mock_user('abcdef', '11111111-2222-3333-4444-555555555555')

    @test_file = Rack::Test::UploadedFile.new(Rails.root.join('test', 'fixtures', 'test_file.xlsx'), '')
    @plate_uploader = PlateUploader.new(test_file)
  end

  test 'upload file' do
    visit lot_path('11111111-2222-3333-4444-555555555556')

    _(page).must_have_content('Create IDT Tag Plate')
    _(page).must_have_content('User swipecard')
    _(page).must_have_content('Select a file to upload')
    _(page).must_have_button('Create IDT Tag Plate')

    within('.swipecard') do
      fill_in 'User swipecard', with: 'abcdef'
    end

    within('.upload') do
      attach_file 'upload', Rails.root.join('test', 'fixtures', 'test_file.xlsx')
    end

    api.qcable_creator.expect_create_with(
      received: {
        user: '11111111-2222-3333-4444-555555555555',
        lot: '11111111-2222-3333-4444-555555555556',
        barcodes: plate_uploader.payload
      },
      returns: '11111111-2222-3333-4444-555555555558'
    )

    click_button('Create IDT Tag Plate')

    assert_current_path '/lots/11111111-2222-3333-4444-555555555556'
  end
end
