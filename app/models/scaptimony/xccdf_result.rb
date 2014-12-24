module Scaptimony
  class XccdfResult < ActiveRecord::Base
    def self.f(result_name)
      where(:name => "#{result_name}").first!
    end
  end
end
