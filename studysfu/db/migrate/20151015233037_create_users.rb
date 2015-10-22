class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :Email
      t.string :FirstName
      t.string :LastName


      t.timestamps null: false
    end
  end
end
