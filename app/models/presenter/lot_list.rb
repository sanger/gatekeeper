# This class displays the information of a list of lots merged together without distinction on the
# provenance of its contents. Also provides the option to access an individual lot presenter in case
# we want to display its information separately
class Presenter::LotList
  attr_reader :lots, :batch_id

  def initialize(batch_id, lots)
    @batch_id = batch_id
    @lots = lots
    @presenters = lots.map{|lot| Presenter::Lot.new(lot)}
  end

  def decision_in_all_qcables?(lot)
    lot.qcables.all?{|qcable| ['available', 'failed'].include?(qcable.state)}
  end

  def decision_for_lot(lot)
    #lot.qcables.all?{|qcable| ['available', 'failed'].include?(qcable.state)}
    decisions = lot.qcables.map(&:state).uniq
    if decisions.count == 1
      return 'available' if decisions.first=='available'
      return 'failed' if decisions.first=='failed'
    end
    return 'unset'
  end

#.select{|lot| !decision_in_all_qcables?(lot)}

  def each_lot_with_its_decision
    @lots.select do |lot|
      lot.lot_type.name == 'Tag 2 Tubes'
    end.each do |lot|
      yield lot, lot.lot_number, lot.uuid, lot.lot_type.name, lot.received_at.to_date.strftime('%d/%m/%Y'), decision_for_lot(lot)
    end
  end

  def presenter_for(lot)
    @presenters[@lots.find_index(lot)]
  end

  def presenter_for_lot_uuid(lot_uuid)
    @presenters.select{|p| p.lot.uuid == lot_uuid}.first
  end

  def each_plate_in(state)
    plates = (sorted_qcables.detect {|qc_state,plates| qc_state == state }||[nil,[]]).last
    Presenter::Qcable.new_from_batch(plates).each do |qcable|
      yield qcable
    end
  end

  def sorted_qcables
    @sorted ||= @lots.map do |lot|
      lot.qcables.group_by {|qcable| qcable.state}
    end.reduce({}) do |memo, val|
      memo.merge(val) {|key, val1, val2| val1.concat(val2)}
    end.sort do |a,b|
      state_index(a.first)<=>state_index(b.first)
    end
  end

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


end
