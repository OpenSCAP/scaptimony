require 'openscap'
require 'openscap/ds/sds'

module Scaptimony
  class Policy < ActiveRecord::Base
    belongs_to :scap_content
    belongs_to :scap_content_profile
    has_many :arf_reports, dependent: :destroy
    has_and_belongs_to_many :assets, :join_table => :scaptimony_assets_policies

    validates :name, :presence => true
  end

  class GuideGenerator
    def initialize(p)
      case p
      when Scaptimony::Policy
        @scap_content = p.scap_content
        @profile = p.scap_content_profile
      end
      if @scap_content.nil? or @scap_content.source.nil?
        OpenSCAP.raise! "Cannot generate HTML Guide for #{@scap_content}/#{@profile}"
      end
    end

    def each
      sds = OpenSCAP::DS::Sds.new @scap_content.source
      sds.select_checklist
      profile_id = @profile.nil? ? nil : @profile.profile_id
      yield sds.html_guide profile_id
      sds.destroy
    end
  end
end
