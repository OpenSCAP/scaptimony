require 'fileutils'
require 'openscap'
require 'openscap/ds/arf'

module Scaptimony
  class ArfReport < ActiveRecord::Base
    belongs_to :asset
    belongs_to :policy

    def store!(data)
      begin
        FileUtils.mkdir_p dir
        File.open(path, 'wb') { |f| f.write(data) }
      rescue StandardError => e
        logger.error "Could not store ARF to '#{path}': #{e.message}"
        raise e
      end
    end

    def each
      OpenSCAP.oscap_init
      arf = OpenSCAP::DS::Arf.new path
      yield arf.html
      arf.destroy
      OpenSCAP.oscap_cleanup
    end

    private
    def path
      "#{dir}/#{digest}.xml.bz2"
    end

    def dir
      # TODO this should be configurable
      "/var/lib/foreman/scaptimony/arf/#{asset.name}/#{policy.name}/#{date}"
    end
  end
end
