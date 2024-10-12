module Reports
  module Products
    class << self
      def most_purchased_by_each_category(products_quantity)
        products_quantity = 1 if products_quantity.blank?

        sql = <<-SQL
          SELECT *
          FROM products
          INNER JOIN sale_orders ON sale_orders.product_id = products.id
          /*WHERE price > 1*/
          ORDER BY name
        SQL

        sql = ActiveRecord::Base.send(:sanitize_sql_array, [sql, products_quantity])
        Product.find_by_sql(sql)
      end
    end
  end
end
