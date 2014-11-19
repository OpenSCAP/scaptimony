module Scaptimony
  class XccdfRuleResult < ActiveRecord::Base
    belongs_to :arf_report
    belongs_to :xccdf_result
    belongs_to :xccdf_rule
  end
end
