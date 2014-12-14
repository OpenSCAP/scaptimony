require 'digest/sha2'
require 'openscap/ds/sds'
require 'openscap/source'
require 'openscap/xccdf/benchmark'
require 'scaptimony/engine'

module Scaptimony
  class DataStreamValidator < ActiveModel::Validator
    def validate(scap_content)
      unless scap_content.new_record?
        return true if scap_content.scap_file_changed?
        scap_content.errors[:base] << _("Cannot change uploaded file while editing content.")
        return false
      end

      if scap_content.scap_file.nil?
        scap_content.errors[:base] << _("Please select file for upload.")
        return false
      end

      allowed_type = 'SCAP Source Datastream'
      if scap_content.source.try(:type) != allowed_type
        scap_content.errors[:base] << _("Uploaded file is not #{allowed_type}.")
        return false
      end

      begin
        scap_content.source.validate!
      rescue OpenSCAP::OpenSCAPError => e
        scap_content.errors[:base] << e.message
      end
    end
  end

  class ScapContent < ActiveRecord::Base
    has_many :scap_content_profiles, :dependent => :destroy
    has_many :policies, :dependent => :destroy

    validates_with Scaptimony::DataStreamValidator
    validates :title, :presence => true
    validates :digest, :presence => true
    validates :scap_file, :presence => true, :uniqueness => true

    after_create :create_profiles

    def to_label
      title
    end

    def source
      @source ||= source_init
    end

    def digest
      self[:digest] ||= Digest::SHA256.hexdigest "#{scap_file}"
    end

    private
    def source_init
      OpenSCAP.oscap_init
      OpenSCAP::Source.new(:content => scap_file)
    end

    def create_profiles
      sds          = ::OpenSCAP::DS::Sds.new source
      bench_source = sds.select_checklist!
      bench        = ::OpenSCAP::Xccdf::Benchmark.new bench_source
      bench.profiles.each { |key, profile|
        scap_content_profiles.create!(:profile_id => key, :title => profile.title)
      }
      bench.destroy
      sds.destroy
      true
    end
  end
end
