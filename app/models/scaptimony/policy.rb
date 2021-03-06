require 'openscap'
require 'openscap/ds/sds'

module Scaptimony
  class Policy < ActiveRecord::Base
    attr_accessible :description, :name, :period, :scap_content_id, :scap_content_profile_id,
                    :weekday, :day_of_month, :cron_line
    belongs_to :scap_content
    belongs_to :scap_content_profile
    has_many :arf_reports, :dependent => :destroy
    has_many :asset_policies
    has_many :assets, :through => :asset_policies

    validates :name, :presence => true

    scoped_search :on => :name, :complete_value => true

    def assign_assets(a)
      self.asset_ids = (self.asset_ids + a.collect(&:id)).uniq
    end

    def to_html
      if self.scap_content.nil? || self.scap_content.source.nil?
        return (_('<h2>Cannot generate HTML guide for %{scap_content}/%{profile}</h2>') %
          { :scap_content => self.scap_content, :profile => self.scap_content_profile }).html_safe
      end

      sds = OpenSCAP::DS::Sds.new self.scap_content.source
      sds.select_checklist
      profile_id = self.scap_content_profile.nil? ? nil : self.scap_content_profile.profile_id
      html = sds.html_guide profile_id
      sds.destroy
      html
    end
  end
end
