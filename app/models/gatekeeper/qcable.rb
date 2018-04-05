# frozen_string_literal: true

##
# Namespcaced Qcable as per:
# https://github.com/sanger/sequencescape-client-api/wiki/Extending-the-Ruby-client-library
# Provides useful methods to move behaviour out of the controllers

class Gatekeeper::Qcable < Sequencescape::Qcable
  include BarcodeExtensions
  include StateExtensions

  def in_lot?(lot)
    self.lot.uuid == lot.uuid
  end
end
