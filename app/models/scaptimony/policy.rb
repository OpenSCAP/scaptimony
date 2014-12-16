require 'openscap'
require 'openscap/ds/sds'

module Scaptimony
  class Policy < ActiveRecord::Base
    attr_accessible :description, :name, :period, :scap_content_id, :scap_content_profile_id, :weekday
    belongs_to :scap_content
    belongs_to :scap_content_profile
    has_many :arf_reports, dependent: :destroy
    has_many :assets_policies
    has_many :assets, :through => :assets_policies

    validates :name, :presence => true

    def assign_assets(a)
      self.asset_ids = (self.asset_ids + a.collect(&:id)).uniq
    end

    def to_html
      if self.scap_content.blank? || self.scap_content_profile.blank?
        return warn(_('Cannot generate HTML guide for %{scap_content}/%{profile}') % {:scap_content => self.scap_content, :profile => self.scap_content_profile})
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
