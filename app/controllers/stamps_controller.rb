##
# Controller to handle stamping of Qcables from lots
# Validation itself is handled by the robot
class StampsController < ApplicationController

  before_filter :find_user
  skip_before_filter :find_user, only: [:new]

  before_filter :find_robot
  skip_before_filter :find_robot, only: [:new]

  before_filter :find_lot
  skip_before_filter :find_lot, only: [:new]

  before_filter :find_bed_contents
  skip_before_filter :find_bed_contents, only: [:new]

  class Validation
    def initialize
      @status = true
      @messages = []
    end

    def status=(new_status)
      @status = @status && new_status
    end

    def add_error(message)
      self.add_message(false,message)
    end

    def add_message(new_status,message)
      self.status = new_status
      @messages  << message
      nil
    end

    def valid?
      @status
    end

    def as_json(options)
      { 'validation' => super }
    end
  end

  ##
  # Presents the stamping interface
  def new
  end

  ##
  # Validates the current bed layout receives parameters
  # :user_swipecard => Handled by find user
  # :robot_barcode  => The barcode of the robot
  # :robot_uuid     => The robot uuid (saves us having to look up by barcode again)
  # :tip_lot        => Metadata only
  # :lot_bed        => The scanned lot bed barcode
  # :lot_plate      => The scanned lot_plate barcode
  # :beds           => Hash of bed barcodes to plate barcodes
  # :validate       => 'lot' or 'full' measures extent of validation
  def validation

    if validator.valid?
      case params[:validate]
      when 'lot'
        validator.add_message(*@robot.valid_lot?(params[:lot_bed],@lot))
      when 'full'
        validator.add_message(*@robot.valid?(params[:lot_bed],@lot,@bed_plates))
      else
        raise StandardError, "An invalid validation option was provided: #{params[:validate]}"
      end
    end

    render(:json=>validator,:root=>true)
  end

  ##
  # Performs a stamp. Expects same parameters as with validate
  # expect validate is not present
  def create
  end

  private


  def validator
    @validator ||= Validation.new
  end

  def find_lot
    @lot = api.search.find(Settings.searches['Find lot by lot number']).all(Sequencescape::Lot,:lot_number=> params[:lot_plate]).tap do |lots|
      validator.add_error("Could not find a lot with the lot number '#{params[:lot_plate]}'") if lots.empty?
      validator.add_error("Multiple lots with lot number #{params[:lot_plate]}. This is currently unsupported.") if lots.count > 1
    end.first
  end

  def find_bed_contents
    return @bed_plates = Hash.new if params[:beds].nil?

    plate_barcodes = params[:beds].values
    validator.add_error("Plates can only be on one bed") if plate_barcodes.uniq.count > plate_barcodes.count

    plates = api.search.find(Settings.searches['Find qcable by barcode']).all(Gatekeeper::Asset,:barcode=> plate_barcodes ).group_by {|plate| plate.barcode.ean13 }
    raise StandardError, 'Multiple Plates with same barcode!' if plates.any? {|_,plates| plates.count > 1}

    @bed_plates = Hash[params[:beds].map do |bed,plate_barcode|
      [bed,plates[plate_barcode]||validator.add_error("Could not find a plate with the barcode #{plate_barcode}.")].flatten
    end]
  end

  ##
  # Attempts to use the uuid to find the robot, but failing that falls back on the barcode search.
  # The latter shouldn't really happen
  def find_robot
    return @robot = api.robot.find(params[:robot_uuid]) if params[:robot_uuid]
    @robot = api.search.find(Settings.searches['Find robot by barcode']).first(:barcode=>params[:robot_barcode])
  end

end
