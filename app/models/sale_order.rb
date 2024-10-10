class SaleOrder < ActiveRecord::Base
  protokoll :sale_number, :pattern => "#"
  attr_accessible :sale_at, :client_id, :product_id, :quantity, :price
  attr_protected :sale_number

  belongs_to :client, class_name: "User"
  belongs_to :product

  delegate :name, to: :client, prefix: true
  delegate :name, to: :product, prefix: true

  def total
    quantity * price
  end
end
