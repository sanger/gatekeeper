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
    @qcable.stamp_index ? @qcable.stamp_index + 1 : '-'
  end

  def barcode
    "#{@qcable.barcode.prefix}#{@qcable.barcode.number}"
  end

  def number
    "#{@qcable.barcode.number}"
  end

  def uuid
    @qcable.uuid
  end

  alias_method :id, :uuid

end
