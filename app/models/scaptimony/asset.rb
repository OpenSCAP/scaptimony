module Scaptimony
  class Asset < ActiveRecord::Base
    has_and_belongs_to_many :policies, :join_table => :scaptimony_assets_policies
    has_many :arf_reports, :dependent => :destroy

    scope :policy_reports, lambda { |*args| includes(:arf_reports).where(:scaptimony_arf_reports => {:policy_id => args.first.id}) }
  end
end
