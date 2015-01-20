require 'openscap'
require 'openscap/ds/arf'
require 'openscap/xccdf/testresult'
require 'openscap/xccdf/ruleresult'

module Scaptimony
  class ArfReportRaw < ActiveRecord::Base
    set_primary_key :arf_report_id
    belongs_to :arf_report
    after_create :save_dependent_entities

    def to_html
      arf = build_arf
      html = arf.html
      arf.destroy
      OpenSCAP.oscap_cleanup
      html
    end

    private

    def save_dependent_entities
      return if arf_report.xccdf_rule_results.any?
      return if size < 0
      begin
        arf = build_arf
        test_result = arf.test_result
        test_result.rr.each {|rr_id, rr|
          rule = ::Scaptimony::XccdfRule.where(:xid => rr_id).first_or_create!
          arf_report.xccdf_rule_results.create!(:xccdf_rule_id => rule.id, :xccdf_result_id => XccdfResult.f(rr.result).id)
        }
      rescue StandardError => e
        arf_report.xccdf_rule_results.destroy_all
        raise e
      ensure
        test_result.destroy unless test_result.nil?
        arf.destroy unless arf.nil?
        OpenSCAP.oscap_cleanup
      end
    end

    def build_arf
      OpenSCAP.oscap_init
      OpenSCAP::DS::Arf.new :content => raw, :path => 'arf.xml.bz2', :length => size
    end
  end
end
