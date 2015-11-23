class AddLimitToBinary < ActiveRecord::Migration
  def change
    change_column :scaptimony_scap_contents, :scap_file, :binary, :limit => 16.megabyte
    change_column :scaptimony_arf_report_raws, :bzip_data, :binary, :limit => 16.megabyte
  end
end
