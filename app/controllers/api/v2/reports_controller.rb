module Api
  module V2
    class ReportsController < BaseController
      swagger_controller :reports, "Report Management"

      def self.add_common_params(api)
        api.response :internal_server_error, "The application raise StandardError Exception. Msg: 'Error Interno en el Servidor. Contacte a Soporte Tecnico'"
      end

      rescue_from Reports::SaleOrder::ValidationError, with: :handle_validation_error

      swagger_api :index do
        summary "Get last two product items"
        param :header, 'Authorization', :string, :required, 'Authorization token'
      end
      def index
        respond_with Product.includes(:created_by).limit(2)
      end

      swagger_api :most_purchased_products_by_each_category do
        summary "Fetches most purchases products by each category"
        notes "Url format example: url?products_limit=2"
        param :header, 'Authorization', :string, :required, 'Authorization token'
        param :query, :products_limit, :integer, :optional, "Limit the most purchased products to show in each category. Default value is 1"
      end
      def most_purchased_products_by_each_category
        respond_with Reports::ProductCategory.most_purchased_products(products_by_each_category_params), root: false
      end

      swagger_api :best_selling_products_by_each_category do
        summary "Fetches best selling products by each category"
        notes "Url format example: url?products_limit=2"
        param :header, 'Authorization', :string, :required, 'Authorization token'
        param :query, :products_limit, :integer, :optional, "Limit the best selling products to show in each category. Default value is 3"
      end
      def best_selling_products_by_each_category
        respond_with Reports::ProductCategory.best_selling_products(products_by_each_category_params), root: false
      end

      swagger_api :sale_orders do |api|
        summary "Fetches sale orders"
        notes "Return sale orders list according query params"
        param :header, 'Authorization', :string, :required, 'Authorization token'
        ReportsController::add_common_params(api)
        param :query, :page, :integer, :required, "The page number to return. Default 1"
        param :query, :rows_per_page, :integer, :optional
        param :query, :sale_at_from, :string, :optional
        param :query, :sale_at_to, :string, :optional
        param :query, :category_id, :integer, :optional
        param :query, :client_id, :integer, :optional
        param :query, :admin_id, :integer, :optional
        response :bad_request, "The application raise Reports::SaleOrder::ValidationError Exception"
      end
      def sale_orders
        respond_with Reports::SaleOrder.all(sale_orders_params), root: false
      end

      swagger_api :sale_orders_quantity do |api|
        summary "Fetches sale orders quantity by granularity"
        notes "Return sale orders quantity according granularity"
        param :header, 'Authorization', :string, :required, 'Authorization token'
        ReportsController::add_common_params(api)
        param :query, :granularity, :string, :required, "The granularity can be one of these values: hour, day, week or year"
        param :query, :sale_at_from, :string, :optional
        param :query, :sale_at_to, :string, :optional
        param :query, :category_id, :integer, :optional
        param :query, :client_id, :integer, :optional
        param :query, :admin_id, :integer, :optional
        response :bad_request, "The application raise Reports::SaleOrder::ValidationError Exception"
      end
      def sale_orders_quantity
        respond_with Reports::SaleOrder.count_by_granularity(sale_orders_quantity_params), root: false
      end

      private

      def products_by_each_category_params
        params.permit(:products_limit)
      end

      def sale_orders_params
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

      def sale_orders_quantity_params
        params.require(:granularity)
        params.permit(:granularity, :sale_at_from, :sale_at_to, :category_id, :client_id, :admin_id)
      end

      def handle_validation_error(e)
        Rails.logger.error e.message
        render json: { message: e.message }, status: :bad_request
      end

    end
  end
end
