module Reports
  module SaleOrder
    ROWS_PER_PAGE_LIMIT = 50
    DEFAULT_ROWS_PER_PAGE = ROWS_PER_PAGE_LIMIT
    ROWS_PER_PAGE = ENV["REPORTS_ROW_PER_PAGE"].to_i # En vez de una variable de entorno, esto se puede guardar en una tabla de configuraciones

    class << self
      def all(params)
        params = {
          page: params["page"].to_i,
          rows_per_page: params.fetch(:rows_per_page, ROWS_PER_PAGE).to_i,
          sale_at_from: params["sale_at_from"].presence,
          sale_at_to: params["sale_at_to"].presence,
          category_id: params["category_id"].presence,
          client_id: params["client_id"].presence, # Devuelve el valor de la clave client_id si no está en blanco, osino devuelve nil
          admin_id: params["admin_id"].presence
        }

        # Se asume que se reciben las fechas en en la zona horaria indicada en application.rb
        # Se parsean estas fechas a un objeto Time con la zona horaria adecuada
        # Luego al pasarle estas fechas a la consulta, Rails hace la magia de convertirlas a UTC para
        # obtener los datos correctamente
        params[:sale_at_from] = Time.zone.parse(params[:sale_at_from]) if params[:sale_at_from]
        params[:sale_at_to] = Time.zone.parse(params[:sale_at_to]) if params[:sale_at_to]
        puts params

        # Alternativa a params["client_id"].presence
        # - params["client_id"].blank? ? nil : params["client_id"]

        params[:rows_per_page] = DEFAULT_ROWS_PER_PAGE if params[:rows_per_page].zero?
        # Lo siguiente es por si a alguien se le ocurre pasar cero lo cual causaría un error
        params[:page] = 1 if params[:page].zero?

        validate_rows_per_page_limit(params[:rows_per_page])

        sql = <<-SQL
          WITH filtered_sale_orders as (
            SELECT sale_orders.id, sale_number, sale_at,
               clients.name AS client, products.id AS product_id, products.name AS product_name,
               admins.name AS admin, quantity, sale_orders.price, (sale_orders.quantity * sale_orders.price) AS total
            FROM sale_orders
            INNER JOIN products ON products.id = sale_orders.product_id
            INNER JOIN users admins ON admins.id = products.created_by_id
            INNER JOIN users clients ON clients.id = sale_orders.client_id
            where (sale_at >= :sale_at_from OR :sale_at_from IS NULL) AND
                  (sale_at <= :sale_at_to OR :sale_at_to IS NULL) AND
                  (clients.id = :client_id OR :client_id IS NULL) AND
                  (admins.id = :admin_id OR :admin_id IS NULL)
            ORDER BY sale_at /* Es muy importante indicar un order al paginar los resultados, osino el orden podria variar en algun momento */
            LIMIT :rows_per_page OFFSET (:page - 1) * :rows_per_page
          ),
          /* Queria mostrar las categorias involucradas y como de por si es un tanto complejo, obtuve exclusivamente las categorias por cada venta
           * en la siguiente consulta, ademas hice un join con las ordenes ya filtradas segun los parametros y paginacion, esto para optimizar y obtener
           * solamente las categorias involucradas en las ventas ya filtradas
          */    
          sale_orders_with_product_categories as (
            SELECT filtered_sale_orders.id, STRING_AGG(pc.name, ', ' ORDER BY pc.name) AS categories 
            FROM product_categories pc
            INNER JOIN product_product_categories ppc ON ppc.product_category_id = pc.id
            INNER JOIN filtered_sale_orders  ON filtered_sale_orders.product_id = ppc.product_id
            WHERE pc.id = :category_id OR :category_id IS NULL
            GROUP BY filtered_sale_orders.product_id, filtered_sale_orders.id
          )
          /* Se realiza de vuelta un join final para obtener especificamente las columnas pertinentes y en el orden deseado */  
          SELECT fso.id, fso.sale_number, fso.sale_at AT TIME ZONE 'UTC' AT TIME ZONE 'America/Santiago' AS sale_at, fso.client, fso.product_name, sowpc.categories, fso.admin, fso.quantity, fso.price, fso.total
          FROM filtered_sale_orders fso
          INNER JOIN sale_orders_with_product_categories sowpc ON sowpc.id = fso.id          
        SQL
        # Cuando se ponen acentos en los comentarios entre /**/ en el código sql me tira el error
        # invalid multibyte char (US-ASCII). Lo indico acá para acordarme por si me vuelve a ocurrir

        # En clients.id = :client_id OR :client_id IS NULL
        # El bloque OR :client_id IS NULL es una forma de ignorar la condición antes del OR cuando se le pasa client_id null
        # esto permite que el parámetro client_id sea opcional. Se hace lo mismo para el resto de parámetros opcionales

        # Se usa fso.sale_at AT TIME ZONE 'UTC' AT TIME ZONE 'America/Santiago' AS sale_at
        # para convertir la fecha de UTC al timezone que maneja el sistema. Tener en cuenta que en las vistas
        # se muestra según la fecha del timezone del sistema y con la conversión en la consulta, las fechas de la vista
        # de sale_orders va coincidir con la fecha devuelta por esta consulta

        # No consideré los problemas de cambio de hora por ejemplo cuando se guarda algo a la media noche antes de un adelanto de hora,
        # cuando se consulte luego del cambio de hora el día va a diferir, esto suele ser molesto.

        ActiveRecord::Base.connection.execute(
          ActiveRecord::Base.send(:sanitize_sql_array, [sql, params])
        )
      end

      private

      # Se limita la cantidad de registros por página que se puede solicitar en la petición
      # esto porque se puede indicar un valor demasiado grande que puede terminar afectando la performance
      # lo cual justamente es lo que se quería evitar obligando que se indique el parámetro page
      def validate_rows_per_page_limit(rows_per_page)
        raise "The limit allow for the param rows_per_page is #{ROWS_PER_PAGE_LIMIT}" if rows_per_page > ROWS_PER_PAGE_LIMIT
      end

    end
  end
end