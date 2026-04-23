# frozen_string_literal: true

module BatchLookup
  private

  def find_lots_for_batch
    @lots = Sequencescape::Api::V2::Lot.where(batch_id: params[:batch_id]).all
    raise Sequencescape::Api::ResourceNotFound, 'Could not find the batch id.' if @lots.nil? || @lots.empty?

    @lots
  end
end
