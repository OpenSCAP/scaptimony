class AddConstraintToScaptimonyScapContents < ActiveRecord::Migration
  def change
    change_column :scaptimony_scap_contents, :title, :string, :null => false
    change_column :scaptimony_scap_contents, :digest, :string, :null => false
  end
end
