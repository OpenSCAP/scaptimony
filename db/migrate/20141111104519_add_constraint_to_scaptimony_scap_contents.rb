class AddConstraintToScaptimonyScapContents < ActiveRecord::Migration
  def change
    change_column :scaptimony_scap_contents, :title, :string, :null => false
  end
end
