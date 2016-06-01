##
# Namespcaced Multiplexed Library Tube as per:
# https://github.com/sanger/sequencescape-client-api/wiki/Extending-the-Ruby-client-library
# Allows us to treat plates and tube the same
class Gatekeeper::MultiplexedLibraryTube < Sequencescape::Tube

  include StateExtensions
  include BarcodeExtensions

  module ModelExtensions
    def children; []; end
    def children?;false; end
  end

  include ModelExtensions

  attr_reader :state

end
