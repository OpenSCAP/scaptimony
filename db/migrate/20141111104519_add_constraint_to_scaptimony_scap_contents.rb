class AddConstraintToScaptimonyScapContents < ActiveRecord::Migration
  def change
    change_column :scaptimony_scap_contents, :title, :null => false
    change_column :scaptimony_scap_contents, :digest, :null => false
  end
end
