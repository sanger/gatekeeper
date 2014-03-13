##
# Provide convenient query methods to inspect the state of an asset
module StateExtensions
  def destroyable?
    Gatekeeper::Application.config.destroyable_states.include?(self.state)
  end
  def qcable?
    Gatekeeper::Application.config.qcable_state == self.state
  end
  def qced?
    Gatekeeper::Application.config.qced_state == self.state
  end
end
