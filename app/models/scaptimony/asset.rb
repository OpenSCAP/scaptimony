module Scaptimony
  class Asset < ActiveRecord::Base
    has_and_belongs_to_many :policies, :join_table => :scaptimony_assets_policies
  end
end
