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
    if @qcable.respond_to?(:labware_barcode)
      lb = @qcable.labware_barcode
      return (lb['human_barcode'] || lb[:human_barcode]).to_s if lb.is_a?(Hash)
    end

    if @qcable.respond_to?(:barcode)
      bc = @qcable.barcode
      if bc.is_a?(Hash)
        return (bc['machine'] || bc[:machine]).to_s if bc['machine'] || bc[:machine]

        return "#{bc['prefix'] || bc[:prefix]}#{bc['number'] || bc[:number]}"
      elsif bc.respond_to?(:machine)
        return bc.machine.to_s if bc.machine
      elsif bc.respond_to?(:prefix) && bc.respond_to?(:number)
        return "#{bc.prefix}#{bc.number}"
      end
    end

    ''
  end

  def barcode
    human_readable
  end

  delegate :uuid, to: :@qcable
  alias id uuid
end
