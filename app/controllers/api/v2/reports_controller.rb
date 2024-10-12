module Api
  module V2
    class ReportsController < ApplicationController
      include Authenticate
      respond_to :json

      def index
        respond_with Product.includes(:created_by).limit(2)
      end

      def most_purchased_products_by_each_category
        respond_with Reports::ProductCategory.most_purchased_products(params[:products_limit])
      end

    end
  end
end
