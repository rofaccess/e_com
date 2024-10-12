module Api
  module V1
    class ReportsController < ApplicationController
      include Authenticate
      def index
        render json: { msg: "The API Version 1 is deprecated" }
      end

    end
  end
end
