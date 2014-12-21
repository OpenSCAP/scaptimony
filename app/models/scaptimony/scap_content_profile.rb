module Scaptimony
  class ScapContentProfile < ActiveRecord::Base
    include Authorizable
    include Taxonomix
    belongs_to :scap_content
    has_many :policies

    def used_location_ids
      Location.joins(:taxable_taxonomies).where(
          'taxable_taxonomies.taxable_type' => 'Scaptimony::ScapContentProfile',
          'taxable_taxonomies.taxable_id' => id).pluck(:id)
    end

    def used_organization_ids
      Organization.joins(:taxable_taxonomies).where(
          'taxable_taxonomies.taxable_type' => 'Scaptimony::ScapContentProfile',
          'taxable_taxonomies.taxable_id' => id).pluck(:id)
    end
  end
end
