class CreateResumes < ActiveRecord::Migration
  def change
    create_table :resumes do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.references :user, index: true, foreign_key: true
      t.text :p1
      t.text :p2
      t.text :p3
      t.text :p4
      t.text :p5
      t.text :p6
      t.text :p7
      t.text :p8
      t.text :p9
      t.text :p10
      t.text :p11
      t.text :p12
      t.text :p13
      t.text :p14
      t.text :p15
      t.text :p16
      t.text :p17
      t.text :p18
      t.text :p19
      t.text :p20

      t.timestamps null: false
    end
    add_index :resumes, [:user_id, :created_at]
  end
end
