module Scaptimony
  class Asset < ActiveRecord::Base
    has_many :assets_policies
    has_many :policies, :through => :assets_policies
    has_many :arf_reports, :dependent => :destroy

    scope :policy_reports, lambda { |policy| includes(:arf_reports).where(:scaptimony_arf_reports => {:policy_id => policy.id}) }
    scope :policy_reports_missing, lambda { |policy| where("id NOT IN (select asset_id from scaptimony_arf_reports where policy_id = #{policy.id})") }
    scope :comply_with, lambda { |policy| last_arf(policy).breakdown.
      last_arf(policy).breakdown.where(:scaptimony_arf_report_breakdowns => {:failed => 0, :othered => 0})
    }
    scope :incomply_with, lambda { |policy|
      last_arf(policy).breakdown.where('scaptimony_arf_report_breakdowns.failed != 0') #TODO:RAILS-4.0: rewrite with: where.not()
    }
    scope :inconclusive_with, lambda { |policy|
      last_arf(policy).breakdown.
      where(:scaptimony_arf_report_breakdowns => {:failed => 0, :othered => 0}).
      where('scaptimony_arf_report_breakdowns.failed != 0') #TODO:RAILS-4.0: rewrite with: where.not()
    }
    scope :breakdown, joins('INNER JOIN scaptimony_arf_report_breakdowns ON scaptimony_arf_reports.id = scaptimony_arf_report_breakdowns.arf_report_id')
    scope :last_arf, lambda { |policy|
      joins("-- this is emo, we need some hipsters to rewrite this using arel
             INNER JOIN (select asset_id, max(id) AS id
             FROM scaptimony_arf_reports
             WHERE policy_id = #{policy.id}
             GROUP BY asset_id) scaptimony_arf_reports
             ON scaptimony_arf_reports.asset_id = scaptimony_assets.id")
    }
  end
end
