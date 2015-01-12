class PolymorphAsset < ActiveRecord::Migration
  def change
    change_table(:scaptimony_assets) do |t|
      t.references :assetable, :polymorphic => true, :index => true
      t.integer :policy_id
      t.remove :name
    end
  end
end
