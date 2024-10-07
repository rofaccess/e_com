# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20241007180517) do

  create_table "clients", :force => true do |t|
    t.string   "name",            :limit => 100, :null => false
    t.string   "document_number", :limit => 20,  :null => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "clients", ["name", "document_number"], :name => "index_clients_on_name_and_document_number", :unique => true

  create_table "product_categories", :force => true do |t|
    t.string   "name",          :limit => 100, :null => false
    t.integer  "created_by_id",                :null => false
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  add_index "product_categories", ["created_by_id"], :name => "index_product_categories_on_created_by_id"
  add_index "product_categories", ["name"], :name => "index_product_categories_on_name", :unique => true

  create_table "product_product_categories", :force => true do |t|
    t.integer  "product_id",          :null => false
    t.integer  "product_category_id", :null => false
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "product_product_categories", ["product_category_id"], :name => "index_product_product_categories_on_product_category_id"
  add_index "product_product_categories", ["product_id", "product_category_id"], :name => "index_prod_prod_cat_on_prod_id_and_prod_cat_id", :unique => true
  add_index "product_product_categories", ["product_id"], :name => "index_product_product_categories_on_product_id"

  create_table "products", :force => true do |t|
    t.string   "name",          :limit => 100,                                :null => false
    t.decimal  "price",                        :precision => 10, :scale => 2, :null => false
    t.integer  "created_by_id",                                               :null => false
    t.datetime "created_at",                                                  :null => false
    t.datetime "updated_at",                                                  :null => false
  end

  add_index "products", ["created_by_id"], :name => "index_products_on_created_by_id"
  add_index "products", ["name"], :name => "index_products_on_name", :unique => true

  create_table "sale_orders", :force => true do |t|
    t.string   "sale_number", :limit => 20,                               :null => false
    t.datetime "sale_at",                                                 :null => false
    t.integer  "client_id",                                               :null => false
    t.integer  "product_id",                                              :null => false
    t.integer  "quantity",                                                :null => false
    t.decimal  "price",                     :precision => 8, :scale => 2, :null => false
    t.datetime "created_at",                                              :null => false
    t.datetime "updated_at",                                              :null => false
  end

  add_index "sale_orders", ["client_id"], :name => "index_sale_orders_on_client_id"
  add_index "sale_orders", ["product_id"], :name => "index_sale_orders_on_product_id"
  add_index "sale_orders", ["sale_number"], :name => "index_sale_orders_on_sale_number", :unique => true

  create_table "users", :force => true do |t|
    t.string   "name",       :limit => 100, :null => false
    t.string   "email",      :limit => 100, :null => false
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

  add_foreign_key "product_categories", "users", name: "product_categories_created_by_id_fk", column: "created_by_id"

  add_foreign_key "product_product_categories", "product_categories", name: "product_product_categories_product_category_id_fk"
  add_foreign_key "product_product_categories", "products", name: "product_product_categories_product_id_fk"

  add_foreign_key "products", "users", name: "products_created_by_id_fk", column: "created_by_id"

  add_foreign_key "sale_orders", "clients", name: "sale_orders_client_id_fk"
  add_foreign_key "sale_orders", "products", name: "sale_orders_product_id_fk"

end
