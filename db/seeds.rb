# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Se utiliza la gema activerecord-import para optimizar la carga del seed
# Además, permite ejecutar varias veces el seed sin que se dupliquen datos, lo que evita lógica extra para validar
# la existencia o no de los datos durante las pruebas en desarrollo

# Users ----------------------------------------------------------------------------------------------------------------
users = [
  { email: "amy@email.com", password: "12345678" },
  { email: "bob@email.com", password: "12345678" },
  { email: "john@email.com", password: "12345678" },
  { email: "dean@email.com", password: "12345678" }
]

User.create(users)
#User.import users, on_duplicate_key_update: {conflict_target: [:email], columns: [:name]}
users = User.select([:name, :id]).index_by(&:name)

# Products -------------------------------------------------------------------------------------------------------------
products = [
  { name: "T-Shirt", price: 30.99, created_by_id: users["Amy"].id },
  { name: "Sweater", price: 50.99, created_by_id: users["Bob"].id },
  { name: "Suit", price: 150.99, created_by_id: users["Bob"].id }
]

Product.import products, on_duplicate_key_update: {conflict_target: [:name], columns: [:price, :created_by_id]}
products = Product.select([:name, :id, :price]).index_by(&:name)

# Product Categories ---------------------------------------------------------------------------------------------------
product_categories = [
  { name: "Clothes", created_by_id: users["Amy"].id },
  { name: "Winter Clothes", created_by_id: users["Amy"].id },
  { name: "Casual Clothes", created_by_id: users["Bob"].id },
  { name: "Formal Clothes", created_by_id: users["Bob"].id }
]

ProductCategory.import product_categories, on_duplicate_key_update: {conflict_target: [:name], columns: [:created_by_id]}
product_categories = ProductCategory.select([:name, :id]).index_by(&:name)

# Product - Product Categories -----------------------------------------------------------------------------------------

product_product_categories = [
  { product_id: products["T-Shirt"].id, product_category_id: product_categories["Clothes"].id },
  { product_id: products["T-Shirt"].id, product_category_id: product_categories["Casual Clothes"].id },
  { product_id: products["Sweater"].id, product_category_id: product_categories["Clothes"].id },
  { product_id: products["Sweater"].id, product_category_id: product_categories["Winter Clothes"].id },
  { product_id: products["Suit"].id, product_category_id: product_categories["Formal Clothes"].id },
]

ProductProductCategory.import product_product_categories, on_duplicate_key_update: {
  conflict_target: [:product_id, :product_category_id], columns: [:product_id, :product_category_id]
}

# Clients --------------------------------------------------------------------------------------------------------------
clients = [
  { name: "John", document_number: "11111" },
  { name: "Dean", document_number: "22222" }
]

Client.import clients, on_duplicate_key_update:  {conflict_target: [:name, :document_number],
                                                  columns: [:name, :document_number]}
clients = Client.select([:name, :id]).index_by(&:name)

# Sale Orders ---------------------------------------------------------------------------------------------------------
sale_orders = [
  { sale_number: "001", sale_at: Time.current, client_id: clients["John"].id, product_id: products["T-Shirt"].id, quantity: 2, price: products["T-Shirt"].price },
  { sale_number: "002",sale_at: Time.current, client_id: clients["John"].id, product_id: products["Sweater"].id, quantity: 5, price: products["Sweater"].price },
  { sale_number: "003",sale_at: Time.current, client_id: clients["Dean"].id, product_id: products["Suit"].id, quantity: 1, price: products["Suit"].price }
]

SaleOrder.import sale_orders, on_duplicate_key_ignore: true
