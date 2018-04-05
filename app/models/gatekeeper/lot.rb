# frozen_string_literal: true

##
# Namespcaced Lot as per:
# https://github.com/sanger/sequencescape-client-api/wiki/Extending-the-Ruby-client-library
# Contains Qcables
# Mainly exists to aid tests
class Gatekeeper::Lot < Sequencescape::Lot
  def pending_qcable_uuids
    qcables.select { |qcable| qcable.pending? }.map(&:uuid)
  end
end
