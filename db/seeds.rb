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

def aleatory_admin
  @_admin_users ||= User.only_admins
  @_admin_users_count ||= @_admin_users.count
  @_admin_users[rand(@_admin_users_count)]
end

def aleatory_client
  @_client_users ||= User.only_clients
  @_client_users_count ||= @_client_users.count
  @_client_users[rand(@_client_users_count)]
end

def aleatory_categories(max_quantity = 5)
  @_categories ||= ProductCategory.all
  @_categories_count ||= @_categories.count
  aleatory_quantity = rand(max_quantity)
  (1..aleatory_quantity).map { |_|  @_categories[rand(@_categories_count)] }.uniq
end

def all_products
  @_all_products ||= Product.all
end

def all_products_count
  @_all_products_count ||= all_products.count
end

def aleatory_product
  @_client_users ||= User.only_clients
  @_client_users_count ||= @_client_users.count
  all_products[rand(all_products_count)]
end

def aleatory_products(max_quantity = 5)
  aleatory_quantity = rand(max_quantity)
  (1..aleatory_quantity).map { |_|  all_products[rand(all_products_count)] }.uniq
end

# Users ----------------------------------------------------------------------------------------------------------------
def create_users
  users = [
    { email: "amy-admin@email.com", password: "12345", is_admin: true },
    { email: "bob-admin@email.com", password: "12345", is_admin: true },
    { email: "john-client@email.com", password: "12345" },
    { email: "dean-client@email.com", password: "12345" }
  ]

  User.create(users)
end

# Product Categories ---------------------------------------------------------------------------------------------------
def create_product_categories(quantity = 10)
  # Faker puede llegar a genear nombres repetidos y el métódo import no puede importar repetidos
  # por eso se construye primero un arreglo de nombres y se usa el métódo uniq
  product_category_names = (1..quantity).map { |_| Faker::Commerce.department(2) }.uniq

  product_categories = product_category_names.map do |product_category_name|
    { name: product_category_name, created_by_id: aleatory_admin.id }
  end

  ProductCategory.import product_categories, on_duplicate_key_ignore: true
end

# Products -------------------------------------------------------------------------------------------------------------
def create_products(quantity = 20)
  product_names = (1..quantity).map { |_| Faker::Commerce.product_name }.uniq
  products = product_names.map do |product_name|
    { name: product_name, price: Faker::Commerce.price, created_by_id: aleatory_admin.id }
  end

  result = Product.import products, on_duplicate_key_ignore: true
  Product.where(id: result.ids)
end

# Product - Product Categories -----------------------------------------------------------------------------------------
def create_product_product_categories(products, max_quantity = 5)
  product_product_categories = products.flat_map do |product|
    aleatory_categories(max_quantity).map do |category|
      { product_id: product.id, product_category_id: category.id }
    end
  end
  ProductProductCategory.import(product_product_categories, on_duplicate_key_ignore: true)
end

# Sale Orders ----------------------------------------------------------------------------------------------------------
def create_sale_orders(quantity = 30)
  last_sale_number = SaleOrder.last_sale_number.to_i

  if last_sale_number.zero?
    SaleOrder.create_sale_number_counter
  end

  # Se crea un arreglo de fechas aleatorias en el rango de un año, las horas son aleatorias para tódo el día
  # En vez de :all se puede indicar :morning si se quieren sólo horas por la mañana
  sale_ats = (1..quantity).map do
    Faker::Time.backward(365, :all)
  end

  # Se ordenan las fechas, esto es para que el numero de venta esté coherente con las fechas
  sale_ats = sale_ats.sort

  sale_orders = sale_ats.map do |sale_at|
    last_sale_number += 1
    product = aleatory_product
    {
      sale_number: last_sale_number.to_s,
      sale_at: sale_at,
      client_id: aleatory_client.id,
      product_id: product.id,
      quantity: Faker::Number.between(1, 100),
      price: product.price
    }
  end

  SaleOrder.update_sale_number_counter(last_sale_number)

  SaleOrder.import sale_orders, on_duplicate_key_ignore: true
end

# Create data
ActiveRecord::Base.transaction do
  create_users

  # En la primera ejecución del seed se crea la cantidad indicada pero en las siguientes ejecuciones ya no se crean
  create_product_categories(15) if ProductCategory.count.zero?

  # Se crean 50 productos por cada ejecución del seed
  products = create_products(50)
  # Se agregan de 1 a 5 categorias aleatorias a los productos creados
  create_product_product_categories(products, 5)

  # Se crean x ventas por cada ejecución del seed
  # Solo en la primera ejecucion los sale_at y sale_number estarán sincronizados, pero a partir de las siguientes
  # ya se verán raros, igual no es grave. Tener en cuenta que el seed se ejecuta cada vez que se levanta el contenedor
  # aunque eso se puede quitar y ejecutar los seed manualmente enviando parametros al contenedor cuando sea necesario
  create_sale_orders(20)
end
