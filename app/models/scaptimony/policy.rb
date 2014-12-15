require 'openscap'
require 'openscap/ds/sds'

module Scaptimony
  class Policy < ActiveRecord::Base
    belongs_to :scap_content
    belongs_to :scap_content_profile
    has_many :arf_reports, dependent: :destroy
    has_and_belongs_to_many :assets, :join_table => :scaptimony_assets_policies

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

  # ## Remove this class if it is un-used elsewhere. move to lib if needed by others.
  # class GuideGenerator
  #   def initialize(p)
  #     case p
  #     when Scaptimony::Policy
  #       @scap_content = p.scap_content
  #       @profile = p.scap_content_profile
  #     end
  #     if @scap_content.nil? or @scap_content.source.nil?
  #       OpenSCAP.raise! "Cannot generate HTML Guide for #{@scap_content}/#{@profile}"
  #     end
  #   end
  #
  #   def each
  #     sds = OpenSCAP::DS::Sds.new @scap_content.source
  #     sds.select_checklist
  #     profile_id = @profile.nil? ? nil : @profile.profile_id
  #     yield sds.html_guide profile_id
  #     sds.destroy
  #   end
  # end
end
