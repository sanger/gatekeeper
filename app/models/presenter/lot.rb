##
# Designed to present information about lots
# Takes an api object and wraps the methods neatly
class Presenter::Lot

  class ConfigurationError < StandardError; end

  attr_reader :name

  def initialize(lot)
    @lot = lot
  end

end
