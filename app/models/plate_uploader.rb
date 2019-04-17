# frozen_string_literal: true

class PlateUploader < ApplicationController
  attr_reader :file, :sheet, :column

  def initialize(file)
    @file = file
    @sheet = Roo::Spreadsheet.open(file, extension: :xlsx).sheet(0)
    @column = sheet.column(3)
    @column.shift
  end

  def barcodes
    @barcodes ||= column.uniq
  end

  def payload
    barcodes.join(',')
  end
end
