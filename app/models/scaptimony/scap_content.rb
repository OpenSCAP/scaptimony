require 'digest'
require 'fileutils'
require 'openscap/source'
require 'scaptimony/engine'

module Scaptimony
  class ScapContent < ActiveRecord::Base
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
