# frozen_string_literal: true

##
# Completed tubes can't have any more requests off them
module QcAssetCreator::Completed
  def plate_create
    raise QcAssetException, "Children can't be created on the final asset in the pipeline."
  end

  def validate
    false
  end
end
