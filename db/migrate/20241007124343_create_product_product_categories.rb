class CreateProductProductCategories < ActiveRecord::Migration
  def change
    create_table :product_product_categories do |t|
      t.integer :product_id, null: false
      t.foreign_key :products

      t.integer :product_category_id, null: false
      t.foreign_key :product_categories

      t.timestamps
    end

    add_index :product_product_categories, [:product_id, :product_category_id],
              name: 'index_prod_prod_cat_on_prod_id_and_prod_cat_id', unique: true
  end
end
