module Scaptimony
  class ArfReportRaw < ActiveRecord::Base
    set_primary_key :arf_report_id
    belongs_to :arf_report
  end
end
