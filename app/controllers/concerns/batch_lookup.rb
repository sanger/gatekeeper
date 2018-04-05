# frozen_string_literal: true

module BatchLookup
  private

  def find_lots_for_batch
    @lots = api.search.find(Settings.searches['Find lot by batch id']).all(
      Gatekeeper::Lot,
      batch_id: params[:batch_id]
    )
    raise Sequencescape::Api::ResourceNotFound, 'Could not find the batch id.' if @lots.nil? || @lots.empty?
    @lots
  end
end
