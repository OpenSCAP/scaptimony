class RemoveDigestFromScaptimonyScapContents < ActiveRecord::Migration
  def change
    remove_column :scaptimony_scap_contents, :digest
  end
end
