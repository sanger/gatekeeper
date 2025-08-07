# frozen_string_literal: true

# Represents a Lot using the Sequencescape V2 API
class Sequencescape::Api::V2::Lot < Sequencescape::Api::V2::Base
  has_one :lot_type
end
