module Api
  module V2
    class ReportsController < ApplicationController
      include Authenticate
      respond_to :json

      def index
        respond_with Product.all
      end

    end
  end
end
