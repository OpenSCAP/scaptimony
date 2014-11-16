module Scaptimony
  class Policy < ActiveRecord::Base
    belongs_to :scap_content
    belongs_to :scap_content_profile
  end
end
