class RenameScaptimonyArfReportRawRaw < ActiveRecord::Migration
  def change
    rename_column :scaptimony_arf_report_raws, :raw, :bzip_data
  end
end
