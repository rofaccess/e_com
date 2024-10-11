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

  class << self
    def last_sale_number
      last.try(:sale_number) || 0
    end

    def update_last_sale_number(last_sale_number)
      ActiveRecord::Base.connection.execute(
        ActiveRecord::Base.send(:sanitize_sql_array, ["UPDATE custom_auto_increments SET counter = ? WHERE model_name = 'sale_order'", last_sale_number])
      )
    end
  end
end
