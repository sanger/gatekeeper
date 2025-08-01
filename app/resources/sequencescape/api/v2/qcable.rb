# frozen_string_literal: true

# Represents a Qcable using the Sequencescape V2 API
class Sequencescape::Api::V2::Qcable < Sequencescape::Api::V2::Base
  has_one :qcable_creator
end