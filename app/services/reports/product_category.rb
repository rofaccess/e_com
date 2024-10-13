module Reports
  module ProductCategory
    class << self
      # Return the most purchased products by each category.
      # @param products_limit [Integer] The products quantity to show by each category
      # @return [Json] A Json array with all categories
      #
      # @example Json result format
      #   [
      #     {
      #       id: 1,
      #       name: "Category Name",
      #       most_purchased_products: [
      #         { id: 1, name: "Product Name", purchased_quantity: 5 }
      #       ]
      #     },
      #     { ... }
      #   ]
      def most_purchased_products(params)
        products_limit = params[:products_limit].blank? ? 1 : params[:products_limit].to_i

        sql = <<-SQL
          WITH ranked_purchased_products_by_category AS (
            SELECT products.id, products.name, SUM(sale_orders.quantity) AS purchased_quantity,
                   product_categories.id AS category_id, product_categories.name AS category_name,
                   ROW_NUMBER() OVER (PARTITION BY product_categories.id ORDER BY SUM(sale_orders.quantity) DESC) AS rank
            FROM products
            INNER JOIN sale_orders ON sale_orders.product_id = products.id
            INNER JOIN product_product_categories ON product_product_categories.product_id = products.id
            INNER JOIN product_categories ON product_categories.id = product_product_categories.product_category_id
            GROUP BY products.id, product_categories.id
          )
          SELECT category_id AS id, category_name AS name, 
                 /*id AS product_id, name AS product_name, purchased_quantity,*/
                 jsonb_agg(jsonb_build_object('id', id, 'name', name, 'purchased_quantity', purchased_quantity)) AS most_purchased_products 
          FROM ranked_purchased_products_by_category products
          WHERE rank <= ?
          GROUP BY category_id, category_name
        SQL

        result = ActiveRecord::Base.connection.execute(
          ActiveRecord::Base.send(:sanitize_sql_array, [sql, products_limit])
        )

        # Convert most_purchased_products in each result from JSON string to JSON
        result.map do |row|
          {
            id: row['id'],
            name: row['name'],
            most_purchased_products: JSON.parse(row["most_purchased_products"]),
          }
        end
      end

      def best_selling_products(params)
        products_limit = params[:products_limit].blank? ? 3 : params[:products_limit].to_i

        sql = <<-SQL
          WITH ranked_best_selling_products_by_category AS (
            SELECT products.id, products.name, SUM(sale_orders.quantity * sale_orders.price) AS sales_total,
                   product_categories.id AS category_id, product_categories.name AS category_name,
                   ROW_NUMBER() OVER (PARTITION BY product_categories.id ORDER BY SUM(sale_orders.quantity * sale_orders.price) DESC) AS rank
            FROM products
            INNER JOIN sale_orders ON sale_orders.product_id = products.id
            INNER JOIN product_product_categories ON product_product_categories.product_id = products.id
            INNER JOIN product_categories ON product_categories.id = product_product_categories.product_category_id
            GROUP BY products.id, product_categories.id
          )
          SELECT category_id AS id, category_name AS name, 
                 /*id AS product_id, name AS product_name, sales_total,*/
                 jsonb_agg(jsonb_build_object('id', id, 'name', name, 'sales_total', sales_total)) AS best_selling_products 
          FROM ranked_best_selling_products_by_category products
          WHERE rank <= ?
          GROUP BY category_id, category_name
        SQL

        result = ActiveRecord::Base.connection.execute(
          ActiveRecord::Base.send(:sanitize_sql_array, [sql, products_limit])
        )

        # Convert best_selling_products in each result from JSON string to JSON
        result.map do |row|
          {
            id: row['id'],
            name: row['name'],
            best_selling_products: JSON.parse(row["best_selling_products"]),
          }
        end
      end

    end
  end
end
