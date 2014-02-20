##
# Designed to present information about qcables
# Used in the rendering of the qcable table on the lot page
class Presenter::Qcable

  class << self
    def new_from_batch(qcables)
      qcables.map {|qcable| Presenter::Qcable.new(qcable)}
    end
  end

  def initialize(qcable)
    @qcable = qcable
  end

  def index
    @qcable.stamp_index||'-'
  end

  def barcode
    @qcable.asset_barcode
  end

  def uuid
    @qcable.uuid
  end
  alias_method :id, :uuid

end
