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

    def create_sale_number_counter
      current_time = Time.current
      ActiveRecord::Base.connection.execute(
        ActiveRecord::Base.send(:sanitize_sql_array, ["INSERT INTO custom_auto_increments (model_name, counter, created_at, updated_at) VALUES (?, ?, ?, ?)", "sale_order", 1, current_time, current_time])
      )
    end

    def update_sale_number_counter(last_sale_number)
      ActiveRecord::Base.connection.execute(
        ActiveRecord::Base.send(:sanitize_sql_array, ["UPDATE custom_auto_increments SET counter = ? WHERE model_name = 'sale_order'", last_sale_number])
      )
    end
  end
end
