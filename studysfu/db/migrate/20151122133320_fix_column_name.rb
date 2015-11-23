class FixColumnName < ActiveRecord::Migration
  def change
    rename_column :resumelists, :type, :section
  end
end