class CreateProductCategories < ActiveRecord::Migration
  def change
    create_table :product_categories do |t|
      t.string :name, limit: 100, null: false

      t.integer :created_by_id, null: false
      t.foreign_key :users, column: :created_by_id

      t.timestamps
    end

    add_index :product_categories, :name, unique: true
  end
end
