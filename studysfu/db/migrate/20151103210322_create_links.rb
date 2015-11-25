class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.string :title, null: false
      t.string :department, null: false
      t.string :course, null: false
      t.text :body, null: false
      t.timestamps null: false

    end
  end
end
