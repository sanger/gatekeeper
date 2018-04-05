# frozen_string_literal: true

##
# Provide convenient query methods to inspect the state of an asset
module StateExtensions
  def destroyable?
    Gatekeeper::Application.config.destroyable_states.include?(state)
  end

  def qcable?
    Gatekeeper::Application.config.qcable_state == state
  end

  def qced?
    Gatekeeper::Application.config.qced_state == state
  end

  def stampable?
    Gatekeeper::Application.config.stampable_state == state
  end

  def pending?
    'pending' == state
  end
end
