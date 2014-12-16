module Scaptimony
  class AssetsPolicy < ActiveRecord::Base
    belongs_to :policy
    belongs_to :asset
  end
end
