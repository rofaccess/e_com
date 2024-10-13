module Api
  module V2
    class ReportsController < ApplicationController
      include Authenticate
      respond_to :json

      def index
        respond_with Product.includes(:created_by).limit(2)
      end

      def most_purchased_products_by_each_category
        respond_with Reports::ProductCategory.most_purchased_products(products_by_each_category_params), root: false
      end

      def best_selling_products_by_each_category
        respond_with Reports::ProductCategory.best_selling_products(products_by_each_category_params), root: false
      end

      def sale_orders
        respond_with Reports::SaleOrder.all(sale_order_params), root: false
      end

      private

      def products_by_each_category_params
        params.permit(:products_limit)
      end

      def sale_order_params
        # Se obliga a indicar una página de forma obligatoria
        # Esto porque al no ser obligatorio ninguno de los otros parámetros, se podría golpear fuertemente la base de datos
        # tratando de obtener toda la información de un tabla potencialmente con muchos registros
        # Aunque el resto de los parámetros fuera obligatorio, igual existe el riesgo de afectar la performance
        # por lo que vale mucho la pena indicar un parámetro page a no ser que se indique explictamente lo contrario, en
        # caso de que se quiera potencialmente traer todos los registros sin importar cuanto se afecta la performance de la petición
        # Otra razón por la que es obligatoria es para indicar que existe el parámetro y es importante ya que igual
        # se pudo indicarlo como opcional con un valor por defecto a 1 en el reporte, acá se entra en el terreno del depende
        params.require(:page) # Obs.: No funciona si se concatena permit en esta línea, es necesario indicar page en la siguiente linea osino considera como unpermitted
        params.permit(:page, :rows_per_page, :sale_at_from, :sale_at_to, :category_id, :client_id, :admin_id)
      end
    end
  end
end
