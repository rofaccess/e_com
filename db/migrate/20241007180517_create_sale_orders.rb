class CreateSaleOrders < ActiveRecord::Migration
  def change
    create_table :sale_orders do |t|
      t.string :sale_number, limit: 20, null: false
      t.datetime :sale_at, null: false

      t.integer :client_id, null: false
      t.foreign_key :users, column: :client_id

      t.integer :product_id, null: false
      t.foreign_key :products

      t.integer :quantity, null: false
      t.decimal :price, null: false, precision: 8, scale: 2

      t.timestamps
    end

    add_index :sale_orders, :sale_number, unique: true
    add_index :sale_orders, :client_id
    add_index :sale_orders, :product_id
  end
end
