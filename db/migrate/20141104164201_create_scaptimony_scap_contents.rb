class CreateScaptimonyScapContents < ActiveRecord::Migration
  def change
    create_table :scaptimony_scap_contents do |t|
      t.string :digest, limit: 128

      t.timestamps
    end
    add_index :scaptimony_scap_contents, :digest, unique: true
  end
end
