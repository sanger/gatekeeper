# frozen_string_literal: true

##
# Designed to present information about qcables
# Used in the rendering of the qcable table on the lot page
class Presenter::Qcable
  class << self
    def new_from_batch(qcables)
      qcables.map { |qcable| Presenter::Qcable.new(qcable) }
    end
  end

  def initialize(qcable)
    @qcable = qcable
  end

  def index
    @qcable.stamp_index ? @qcable.stamp_index + 1 : '-'
  end

  def human_readable
    labware_human_barcode ||
      barcode_machine ||
      barcode_prefix_number ||
      ''
  end

  def barcode
    human_readable
  end

  private

  def labware_human_barcode
    return unless @qcable.respond_to?(:labware_barcode)

    lb = @qcable.labware_barcode
    return unless lb.is_a?(Hash)

    (lb['human_barcode'] || lb[:human_barcode])&.to_s
  end

  def barcode_machine
    return unless @qcable.respond_to?(:barcode)

    bc = @qcable.barcode

    if bc.is_a?(Hash)
      machine = bc['machine'] || bc[:machine]
      machine&.to_s
    elsif bc.respond_to?(:machine)
      bc.machine&.to_s
    end
  end

  def barcode_prefix_number
    return unless @qcable.respond_to?(:barcode)

    bc = @qcable.barcode

    if bc.is_a?(Hash)
      prefix = bc['prefix'] || bc[:prefix]
      number = bc['number'] || bc[:number]
      "#{prefix}#{number}"
    elsif bc.respond_to?(:prefix) && bc.respond_to?(:number)
      "#{bc.prefix}#{bc.number}"
    end
  end

  delegate :uuid, to: :@qcable
  alias id uuid
end
