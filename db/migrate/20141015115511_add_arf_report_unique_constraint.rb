class AddArfReportUniqueConstraint < ActiveRecord::Migration
  def change
    add_index :scaptimony_arf_reports, [:assert_id, :policy_id, :date, :digest], :unique => true)
  end
end
