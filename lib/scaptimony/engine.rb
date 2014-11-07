module Scaptimony
  class Engine < ::Rails::Engine
    isolate_namespace Scaptimony
    def self.dir
      # TODO this should be configurable
      '/var/lib/foreman/scaptimony'
    end
  end
end
