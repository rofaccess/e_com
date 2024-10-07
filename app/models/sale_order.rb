class SaleOrder < ActiveRecord::Base
  attr_accessible :sale_number, :sale_at, :client_id, :product_id, :quantity, :price

  belongs_to :client
  belongs_to :product
end
