class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name, limit: 100, null: false
      t.decimal :price, precision: 10, scale: 2, null: false

      t.integer :created_by_id, null: false
      t.foreign_key :users, column: :created_by_id

      t.timestamps
    end

    add_index :products, :name, unique: true
  end
end
