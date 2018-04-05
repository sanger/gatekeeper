# frozen_string_literal: true

##
# Namespcaced Asset as per:
# https://github.com/sanger/sequencescape-client-api/wiki/Extending-the-Ruby-client-library
# Allows us to grab the purpose via purpose regardless of whether we have a plate or tube
class Gatekeeper::Plate < Sequencescape::Plate
  module ModelExtensions
    def purpose
      plate_purpose
    end

    def children
      children? ? (
        source_transfers.map do |st|
          st.destination
        end) :
        []
    end

    def children?
      source_transfers.size > 0
    end
  end

  include ModelExtensions
  include StateExtensions
  include BarcodeExtensions
end
