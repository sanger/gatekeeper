##
# Namespcaced Qcable as per:
# https://github.com/sanger/sequencescape-client-api/wiki/Extending-the-Ruby-client-library
# Provides useful methods to move behaviour out of the controllers

class Gatekeeper::Qcable < Sequencescape::Qcable

  include BarcodeExtensions

  def in_lot?(lot)
    selt.lot.uuid == lot.uuid
  end

  def stampable?
    self.state == Gatekeeper::Application.config.stampable_state
  end

end
