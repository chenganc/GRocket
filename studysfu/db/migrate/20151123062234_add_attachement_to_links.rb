class AddAttachementToLinks < ActiveRecord::Migration
  def change
    add_column :links, :attachment, :string
  end
end
