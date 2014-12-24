require 'fileutils'
require 'openscap'
require 'openscap/ds/arf'
require 'openscap/xccdf/testresult'
require 'openscap/xccdf/ruleresult'
require 'scaptimony/engine'

module Scaptimony
  class ArfReport < ActiveRecord::Base
    belongs_to :asset
    belongs_to :policy
    has_many :xccdf_rule_results, :dependent => :destroy
    has_one :arf_report_breakdown

    before_destroy { |record|
      record.delete
    }

    scope :last, lambda { order('date DESC').first }
    scope :breakdown, joins(:arf_report_breakdown)
    scope :comply, breakdown.where(:scaptimony_arf_report_breakdowns => { :failed => 0, :othered => 0 })
    scope :incomply, breakdown.where('scaptimony_arf_report_breakdowns.failed != 0') # TODO:RAILS-4.0: where.not
    scope :inconclusive, breakdown.where(:scaptimony_arf_report_breakdowns => { :failed => 0, :othered => 0 })
    scope :latest, joins('INNER JOIN (select asset_id, policy_id, max(id) AS id
                          FROM scaptimony_arf_reports
                          GROUP BY asset_id, policy_id) latest
                          ON scaptimony_arf_reports.id = latest.id')

    scoped_search :on => :date, :complete_value => true, :default_order => :desc
    scoped_search :in => :arf_report_breakdown, :on => :passed
    scoped_search :in => :arf_report_breakdown, :on => :failed
    scoped_search :in => :arf_report_breakdown, :on => :othered
    scoped_search :in => :policy, :on => :name, :complete_value => true, :rename => :compliance_policy
    scoped_search :on => :id, :rename => :last_for, :complete_value => { :host => 0, :policy => 1 },
      :only_explicit => true, :ext_method => :search_by_last_for
    scoped_search :in => :policy, :on => :name, :complete_value => true, :rename => :comply_with,
      :only_explicit => true, :operators => ['= '], :ext_method => :search_by_comply_with
    scoped_search :in => :policy, :on => :name, :complete_value => true, :rename => :not_comply_with,
      :only_explicit => true, :operators => ['= '], :ext_method => :search_by_not_comply_with
    scoped_search :in => :policy, :on => :name, :complete_value => true, :rename => :inconclusive_with,
      :only_explicit => true, :operators => ['= '], :ext_method => :search_by_inconclusive_with

    def passed; arf_report_breakdown ? arf_report_breakdown.passed : 0; end
    def failed; arf_report_breakdown ? arf_report_breakdown.failed : 0; end
    def othered; arf_report_breakdown ? arf_report_breakdown.othered : 0; end

    def store!(data)
      begin
        FileUtils.mkdir_p dir
        File.open(path, 'wb') { |f| f.write(data) }
        save_dependent_entities
      rescue StandardError => e
        logger.error "Could not store ARF to '#{path}': #{e.message}"
        raise e
      end
    end

    def to_html
      OpenSCAP.oscap_init
      arf = OpenSCAP::DS::Arf.new path
      html = arf.html
      arf.destroy
      OpenSCAP.oscap_cleanup
      html
    end

    def delete
      File.delete path
      begin
        Dir.delete dir
      rescue StandardError => e
      end
    end

    private
    def save_dependent_entities
      return unless xccdf_rule_results.empty?
      begin
        OpenSCAP.oscap_init
        arf = OpenSCAP::DS::Arf.new path
        test_result = arf.test_result
        test_result.rr.each {|rr_id, rr|
          rule = ::Scaptimony::XccdfRule.where(:xid => rr_id).first_or_create!
          xccdf_rule_results.create!(:xccdf_rule_id => rule.id, :xccdf_result_id => XccdfResult.f(rr.result).id)
        }
      rescue StandardError => e
        xccdf_rule_results.destroy_all
        raise e
      ensure
        test_result.destroy unless test_result.nil?
        arf.destroy unless arf.nil?
        OpenSCAP.oscap_cleanup
      end
    end

    def path
      "#{dir}/#{digest}.xml.bz2"
    end

    def dir
      # TODO this should be configurable
      "#{Scaptimony::Engine.dir}/arf/#{asset.name}/#{policy.name}/#{date}"
    end

    def self.search_by_comply_with(_key, _operator, policy_name)
      search_by_policy_results policy_name, &:comply
    end

    def self.search_by_not_comply_with(_key, _operator, policy_name)
      search_by_policy_results policy_name, &:incomply
    end

    def self.search_by_inconclusive_with(_key, _operator, policy_name)
      search_by_policy_results policy_name, &:inconclusive
    end

    def self.search_by_policy_results(policy_name, &selection)
      cond = sanitize_sql_for_conditions('scaptimony_policies.name' => policy_name)
      { :conditions => Scaptimony::ArfReport.arel_table[:id].in(
          Scaptimony::ArfReport.select(Scaptimony::ArfReport.arel_table[:id])
            .latest.instance_eval(&selection).joins(:policy).where(cond).ast
        ).to_sql
      }
    end

    def self.search_by_last_for(key, operator, by)
      by.gsub!(/[^[:alnum:]]/, '')
      case by.downcase
      when 'host'
        { :conditions => 'scaptimony_arf_reports.id IN (
              SELECT MAX(id) FROM scaptimony_arf_reports sub
              WHERE sub.asset_id = scaptimony_arf_reports.asset_id)' }
      when 'policy'
        { :conditions => 'scaptimony_arf_reports.id IN (
              SELECT MAX(id) FROM scaptimony_arf_reports sub
              WHERE sub.policy_id = scaptimony_arf_reports.policy_id)' }
      else
        raise "Cannot search last by #{by}"
      end
    end
  end
end
