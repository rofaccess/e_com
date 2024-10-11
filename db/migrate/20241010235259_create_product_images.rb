class CreateProductImages < ActiveRecord::Migration
  def change
    create_table :product_images do |t|
      t.integer :product_id, null: false
      t.foreign_key :products

      t.attachment :image

      t.timestamps
    end

    add_index :product_images, :product_id
  end
end
