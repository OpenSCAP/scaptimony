module Scaptimony
  class AssetPolicy < ActiveRecord::Base
    belongs_to :policy
    belongs_to :asset
  end
end
