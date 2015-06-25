##
# Designed to present information about lots
# Takes an api object and wraps the methods neatly
class Presenter::Lot

  class ConfigurationError < StandardError; end

  attr_reader :lot

  def initialize(lot)
    @lot = lot
  end

  delegate :lot_number, :uuid, :id, :lot_type_name, :template_name, :to=> :lot
  alias_method :lot_type, :lot_type_name
  alias_method :template, :template_name

  # Lets us pass our presenter into rails url helpers
  alias_method :to_param, :uuid

  def received_at
    @lot.received_at.to_date.strftime('%d/%m/%Y')
  end

  def max_qcables
  end

  def min_qcables
  end

  def step_qcables
  end

  def total_plates
    @total||= @lot.qcables.count
  end

  def child_type
    lot.lot_type.qcable_name
  end

  def printer_type
    lot.lot_type.printer_type
  end

  def prefix
    return '' if @lot.qcables.empty?
    @lot.qcables.first.barcode.prefix
  end

  ##
  # Returns each state, excluding any passed in as arguments
  # Aliased as each_state for readability where all states are needed
  def each_state_except(reject=[])
    state_counts.reject{|k,_| reject.include?(k) }.each do |state,count|
      yield(state,count,count*100.0/total_plates)
    end
  end
  alias_method :each_state, :each_state_except

  ##
  # Yields for each state, and provides an array of Qcable presenters
  def each_state_and_children(reject=[])
    sorted_qcables.each do |state,qcables|
      yield state, Presenter::Qcable.new_from_batch(qcables)
    end
  end

  def each_plate_in(state)
    plates = (sorted_qcables.detect {|qc_state,plates| qc_state == state }||[nil,[]]).last
    Presenter::Qcable.new_from_batch(plates).each do |qcable|
      yield qcable
    end
  end

  ##
  # Keeps track of the active tab. It will return true the first time it is called,
  # and subsequently is called with the same state again.
  def active?(state)
    (@active||=state) == state ? 'active' : ''
  end

  private

  def state_index(state)
    [
      'created',
      'qc_in_progress',
      'failed',
      'destroyed',
      'passed',
      'exhausted',
      'pending',
      'available'
     ].index(state)
  end

  def sorted_qcables
    @sorted ||= @lot.qcables.group_by {|qcable| qcable.state }.sort {|a,b| state_index(a.first)<=>state_index(b.first)}
  end

  def state_counts
    @counts ||= sorted_qcables.map {|state,qcables| [state,qcables.count]}
  end

end
