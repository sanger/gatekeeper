# frozen_string_literal: true

class QcDecisionsController < ApplicationController
  include BatchLookup

  def find_lot_presenter
    @lot_presenter = Presenter::Lot.new(Sequencescape::Api::V2::Lot.find(params[:lot_id]))
  end
end
