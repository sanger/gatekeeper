# frozen_string_literal: true

##
# Namespcaced Asset as per:
# https://github.com/sanger/sequencescape-client-api/wiki/Extending-the-Ruby-client-library
# Allows us to treat plates and tube the same
class Gatekeeper::Tube < Sequencescape::Tube
  include StateExtensions
  include BarcodeExtensions

  module ModelExtensions
    def children
      children? ? requests.map { |r| r.target_asset } : []
    end

    def children?
      requests.size > 0
    end
  end

  include ModelExtensions

  attr_reader :state
end
