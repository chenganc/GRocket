class CreateResumelists < ActiveRecord::Migration
  def change
    create_table :resumelists do |t|
      t.text :content
      t.string :type
      t.date :start
      t.date :finish
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
    # change_table :resumelists do |t|
    #   t.string :section
    #   #t.rename :type, :section
    # end
    add_index :resumelists, [:user_id, :created_at]
  end
end
