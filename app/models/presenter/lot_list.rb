# frozen_string_literal: true

# This class displays the information of a list of lots merged together without distinction on the
# provenance of its contents. Also provides the option to access an individual lot presenter in case
# we want to display its information separately
class Presenter::LotList
  attr_reader :lots, :batch_id

  def initialize(batch_id, lots)
    @batch_id = batch_id
    @lots = lots
    @presenters = lots.map { |lot| Presenter::Lot.new(lot) }
  end

  def each_lot(&)
    @presenters.each(&)
  end
end
