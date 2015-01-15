require 'digest/sha2'

class AddScaptimonyScapContentDigest < ActiveRecord::Migration
  def change
    add_column :scaptimony_scap_contents, :digest, :string, :limit => 128
    ScapContentHack.find_each do |content|
      content.digest
      content.save!
    end
    change_column :scaptimony_scap_contents, :digest, :string, :null => false
    add_index :scaptimony_scap_contents, :digest, unique: true
  end

  class ScapContentHack < ActiveRecord::Base
    self.table_name = 'scaptimony_scap_contents'
    def digest
      self[:digest] ||= Digest::SHA256.hexdigest "#{scap_file}"
    end
  end
end
