##
# Namespcaced Asset as per:
# https://github.com/sanger/sequencescape-client-api/wiki/Extending-the-Ruby-client-library
# Provides useful methods to move behaviour out of the controllers

class Gatekeeper::Asset < Sequencescape::Asset

  include BarcodeExtensions

  module StateExtensions
    def destroyable?
      Gatekeeper::Application.config.destroyable_states.include?(self.state)
    end
  end

  include StateExtensions

end
