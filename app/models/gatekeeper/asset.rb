##
# Namespcaced Asset as per:
# https://github.com/sanger/sequencescape-client-api/wiki/Extending-the-Ruby-client-library
# Provides useful methods to move behaviour out of the controllers

class Gatekeeper::Asset < Sequencescape::BarcodedAsset

  include BarcodeExtensions
  include StateExtensions

end
