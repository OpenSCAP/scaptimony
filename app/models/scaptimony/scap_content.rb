require 'openscap/ds/sds'
require 'openscap/source'
require 'openscap/xccdf/benchmark'
require 'scaptimony/engine'

module Scaptimony
  class DataStreamValidator < ActiveModel::Validator
    def validate(scap_content)
      return unless scap_content.scap_file_changed?

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

      unless (scap_content.scap_content_profiles.map(&:profile_id) - scap_content.benchmark_profiles.profiles.keys).empty?
        scap_content.errors[:base] << _("Changed file does not include existing Scap Content profiles.")
        return false
      end
    end
  end

  class ScapContent < ActiveRecord::Base
    has_many :scap_content_profiles, :dependent => :destroy
    has_many :policies

    before_destroy EnsureNotUsedBy.new(:policies)

    validates_with Scaptimony::DataStreamValidator
    validates :title, :presence => true
    validates :scap_file, :presence => true, :uniqueness => true

    after_save :create_profiles

    scoped_search :on => :title,             :complete_value => true
    scoped_search :on => :original_filename, :complete_value => true, :rename => :filename

    def to_label
      title
    end

    def source
      @source ||= source_init
    end

    # returns OpenSCAP::Xccdf::Benchmark with profiles.
    def benchmark_profiles
      sds          = ::OpenSCAP::DS::Sds.new(source)
      bench_source = sds.select_checklist!
      benchmark = ::OpenSCAP::Xccdf::Benchmark.new(bench_source)
      sds.destroy
      benchmark
    end

    private
    def source_init
      OpenSCAP.oscap_init
      OpenSCAP::Source.new(:content => scap_file)
    end

    def create_profiles
      bench = benchmark_profiles
      bench.profiles.each { |key, profile|
        scap_content_profiles.find_or_create_by_profile_id_and_title(key, profile.title)
      }
      bench.destroy

    end

  end
end
