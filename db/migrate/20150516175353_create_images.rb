class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :url, unique: true
      t.string :gender
      t.integer :age
      t.string :sid
      t.text :alikes

      t.timestamps null: false
    end
  end
end
