module Api
  # Idealmente, BaseController debería heredar de ActionController::Base, pero si es así la tarea rake swagger:docs no genera
  # la documentación de las APIs de ReportsController. Por eso se hereda de ApplicationController con el cual si se genera
  # correctamente la documentación aunque ApplicationController tenga métodos que no se usan en este contexto.
  class BaseController < ApplicationController
    include Authenticate
    respond_to :json

    rescue_from StandardError, with: :handle_standard_error

    private

    def handle_standard_error(e)
      Rails.logger.error e.message
      # TODO No le gusta el acento en Técnico, debo ver como hacerlo funcionar
      render json: { message: "Error Interno en el Servidor. Contacte a Soporte Tecnico" }, status: :internal_server_error
    end

    class << self
      Swagger::Docs::Generator::set_real_methods

      def inherited(subclass)
        super
        subclass.class_eval do
          setup_basic_api_documentation
        end
      end

      private
      def setup_basic_api_documentation
        [:most_purchased_products_by_each_category, :best_selling_products_by_each_category, :sale_orders, :sale_orders_quantity].each do |api_action|
          swagger_api api_action do
            # Lo siguiente no funciona, es decir, no se agrega
            param :header, 'Authorization', :string, :required, 'Authorization token'
            # Al repetir :unauthorized, sólo se muestra el último en swagger-ui
            response :unauthorized, "JWT Token decode error"
            response :unauthorized, "Invalid JWT Token"
            response :unauthorized, "User authorization fails"
            response :unauthorized, "Authorization header is missing"
          end
        end
      end
    end

  end
end
