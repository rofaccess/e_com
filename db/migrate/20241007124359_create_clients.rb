class CreateClients < ActiveRecord::Migration
  def change
    create_table :clients do |t|
      t.string :name, limit: 100, null: false
      t.string :document_number, limit: 20, null: false

      t.timestamps
    end

    add_index :clients, [:name, :document_number], unique: true
  end
end
