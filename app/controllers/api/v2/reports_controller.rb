module Api
  module V2
    class ReportsController < ApplicationController
      include Authenticate
      respond_to :json

      def index
        respond_with ProductCategory.limit(2)
      end

      def most_purchased_products_by_each_category
        respond_with Reports::Products.most_purchased_by_each_category(params[:products_quantity])
      end

    end
  end
end
