module Scaptimony
  class Asset < ActiveRecord::Base
    has_and_belongs_to_many :policies, :join_table => :scaptimony_assets_policies
    has_many :arf_reports, :dependent => :destroy

    scope :policy_reports, lambda { |*args| includes(:arf_reports).where(:scaptimony_arf_reports => {:policy_id => args.first.id}) }
    scope :comply_with, lambda { |*args|
      joins("-- this is emo, we need some histers to rewrite this using arel
             INNER JOIN (select asset_id, max(id) AS id
             FROM scaptimony_arf_reports
             WHERE policy_id = #{args.first.id}
             GROUP BY asset_id) scaptimony_arf_reports
             ON scaptimony_arf_reports.asset_id = scaptimony_assets.id").
      joins('INNER JOIN scaptimony_arf_report_breakdowns
             ON scaptimony_arf_reports.id = scaptimony_arf_report_breakdowns.arf_report_id').
      where(:scaptimony_arf_report_breakdowns => {:failed => 0, :othered => 0})
    }
  end
end
