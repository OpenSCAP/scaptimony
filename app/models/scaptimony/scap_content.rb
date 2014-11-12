require 'digest'
require 'fileutils'
require 'openscap/source'
require 'scaptimony/engine'

module Scaptimony
  class DataStreamValidator < ActiveModel::Validator
    def validate(scap_content)
      if !scap_content.new_record?
        return true if scap_content.scap_file.nil?
        scap_content.errors[:base] << _("Cannot change uploaded file while editing content.")
        return false
      end
      if scap_content.scap_file.nil?
        scap_content.errors[:base] << _("Please select file for upload.")
        return false
      end

      existing = ScapContent.where(:digest => scap_content.digest).first
      if !existing.nil?
        scap_content.errors[:base] << _("This file has been already uploaded as '#{existing.title}'.")
        return false
      end

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
    validates :title, :presence => true
    validates :digest, :presence => true
    attr_accessor :scap_file

    def store
      if valid_store_attempt
        begin
          FileUtils.mkdir_p dir
          source.save path
        rescue StandardError => e
          errors[:base] << e.message
          return false
        end
      end
      save
    end

    def valid_store_attempt
      new_record? and !@scap_file.nil?
    end

    def source
      @source ||= source_init
    end

    def digest
      self[:digest] ||= Digest::SHA256.hexdigest "#{@scap_file}"
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
