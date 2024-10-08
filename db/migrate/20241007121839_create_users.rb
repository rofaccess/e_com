class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name, limit: 100, null: false
      t.boolean :is_admin, default: false

      t.timestamps
    end
  end
end
