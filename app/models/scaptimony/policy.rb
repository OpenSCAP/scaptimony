module Scaptimony
  class Policy < ActiveRecord::Base
    belongs_to :scap_content
  end
end
