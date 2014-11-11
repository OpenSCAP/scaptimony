require 'digest'
require 'fileutils'
require 'openscap/source'
require 'scaptimony/engine'

module Scaptimony
  class DataStreamValidator < ActiveModel::Validator
    def validate(scap_content)
      allowed_type = 'SCAP Source Datastream'
      if scap_content.source.type != allowed_type
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
    validates_with Scaptimony::DataStreamValidator
    attr_writer :scap_file

    def store
      begin
        FileUtils.mkdir_p dir
        source.save path
      rescue StandardError => e
        errors[:base] << e.message
        return false
      end
      save
    end

    def source
      @source ||= source_init
    end

    def digest
      @digest ||= Digest::SHA256.hexdigest @scap_file
    end

    private
    def source_init
      OpenSCAP.oscap_init
      OpenSCAP::Source.new(:content => @scap_file, :path => path)
    end

    def path
      "#{dir}/#{digest}"
    end

    def dir
      "#{Scaptimony::Engine.dir}/content"
    end
  end
end
