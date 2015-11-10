class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.string :title
      t.string :course
      t.text :body
      t.timestamps null: false
    end
  end
end
