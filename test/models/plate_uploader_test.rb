# frozen_string_literal: true

require 'test_helper'

class PlateUploaderTest < ActiveSupport::TestCase
  attr_reader :test_file, :plate_uploader

  setup do
    @test_file = Rack::Test::UploadedFile.new(Rails.root.join('test', 'fixtures', 'test_file.xlsx'), '')
    @plate_uploader = PlateUploader.new(test_file)
  end

  it 'returns the right number of barcodes' do
    assert_equal 10, plate_uploader.barcodes.length
    assert_equal 11842563, plate_uploader.barcodes.first
    assert_equal 11842572, plate_uploader.barcodes.last
  end
end
