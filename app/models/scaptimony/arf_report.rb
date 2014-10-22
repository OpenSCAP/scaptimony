require 'fileutils'

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
