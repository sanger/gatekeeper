# frozen_string_literal: true

# Represents a QcableCreator using the Sequencescape V2 API
class Sequencescape::Api::V2::QcableCreator < Sequencescape::Api::V2::Base
  has_one :lot
  has_one :user
  has_many :qcables
end