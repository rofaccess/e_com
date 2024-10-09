class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name, limit: 100, null: false
      t.decimal :price, precision: 10, scale: 2, null: false

      t.integer :created_by_id, null: false
      t.foreign_key :users, column: :created_by_id

      t.datetime :deleted_at

      t.timestamps
    end

    add_index :products, :name, unique: true
    add_index :products, :created_by_id
  end
end

# Obs.:
# - Se usa la gema foreigner porque ya agrega las restricciones de clave foránea, en cambio t.references sólo crea estas
#   restricciones a partir de Rails 4
# - Se recomienda agregar índices a las claves foráneas para optimizar el rendimiento de consultas que utilicen join
