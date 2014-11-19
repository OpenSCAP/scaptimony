class AddDescriptionToScaptimonyXccdfResults < ActiveRecord::Migration
  def change
    add_column :scaptimony_xccdf_results, :description, :string
  end
end
