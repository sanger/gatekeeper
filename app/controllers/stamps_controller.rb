# frozen_string_literal: true

##
# Controller to handle stamping of Qcables from lots
# Validation itself is handled by the robot
class StampsController < ApplicationController
  before_action :find_user
  skip_before_action :find_user, only: [:new]

  before_action :find_robot
  skip_before_action :find_robot, only: [:new]

  before_action :find_lot
  skip_before_action :find_lot, only: [:new]

  before_action :find_bed_contents
  skip_before_action :find_bed_contents, only: [:new]

  class Validation
    def initialize
      @status = true
      @messages = []
    end

    def status=(new_status)
      @status &&= new_status
    end

    def add_error(message)
      add_message(false, message)
    end

    def add_message(new_status, message)
      self.status = new_status
      @messages << message
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
    @params = params
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
    case params[:validate]
    when 'lot'
      validator.add_message(*@robot.valid_lot?(params[:lot_bed], @lot)) unless @robot.nil?
    when 'full'
      if validator.valid?
        validator.add_message(*@robot.valid?(params[:lot_bed], @lot, @bed_plates))
      end
    else
      raise StandardError, "An invalid validation option was provided: #{params[:validate]}"
    end

    render(json: validator, root: true)
  end

  ##
  # Performs a stamp. Expects same parameters as with validate
  # except validate is not present
  def create
    valid, _ = @robot.valid?(params[:lot_bed], @lot, @bed_plates)
    # A last emergency catch all in case someone bypasses the client side controls
    raise StandardError, 'Validation Bypassed' unless valid

    api.stamp.create!(
      user: @user.uuid,
      robot: @robot.uuid,
      lot: @lot.uuid,
      tip_lot: params[:tip_lot],
      stamp_details: @robot.beds_for(@bed_plates)
    )

    flash[:success] = 'Stamp completed!'
    redir = params[:repeat].present? ?
      {
        controller: :stamps,
        action: :new,
        robot_barcode: params[:robot_barcode],
        tip_lot: params[:tip_lot],
        lot_bed: params[:lot_bed],
        lot_plate: params[:lot_plate]
      } :
      lot_url(@lot)
    redirect_to redir
  end

  private

  def validator
    @validator ||= Validation.new
  end

  def find_lot
    @lot = api.search.find(Settings.searches['Find lot by lot number']).all(Gatekeeper::Lot, lot_number: params[:lot_plate]).tap do |lots|
      validator.add_error("Could not find a lot with the lot number '#{params[:lot_plate]}'") if lots.empty?
      validator.add_error("Multiple lots with lot number #{params[:lot_plate]}. This is currently unsupported.") if lots.count > 1
    end.first
  end

  def find_bed_contents
    return @bed_plates = Hash.new if params[:beds].nil?

    plate_barcodes = params[:beds].values
    validator.add_error('Plates can only be on one bed') if plate_barcodes.uniq!.present?

    plates = api.search.find(Settings.searches['Find qcable by barcode']).all(Gatekeeper::Qcable, barcode: plate_barcodes).group_by { |plate| plate.barcode.ean13 }
    raise StandardError, 'Multiple Plates with same barcode!' if plates.any? { |_, plates| plates.count > 1 }

    @bed_plates = Hash[params[:beds].permit!.to_h.map do |bed, plate_barcode|
      [bed, plates[plate_barcode] || validator.add_error("Could not find a plate with the barcode #{plate_barcode}.")].flatten
    end]
  end

  ##
  # Attempts to use the uuid to find the robot, but failing that falls back on the barcode search.
  def find_robot
    return @robot = api.robot.find(params[:robot_uuid]) if params[:robot_uuid]
    begin
      @robot = api.search.find(Settings.searches['Find robot by barcode']).first(barcode: params[:robot_barcode])
    rescue Sequencescape::Api::ResourceNotFound => exception
      return validator.add_error("Could not find robot with barcode #{params[:robot_barcode]}")
    end
  end
end
