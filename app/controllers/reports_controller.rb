require "api/jwt_token"

class ReportsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_admin
  def index
    @jwt_token = JwtToken.encode({ user_id: current_user.id })
    @apis = {
      deprecated_api: "curl -w '\\n' -H 'Accept: application/vnd.example.v1' -H 'Authorization: #{@jwt_token}' http://localhost:3000/api/reports",
      most_purchased_products_by_category: "curl -w '\\n' -H 'Authorization: #{@jwt_token}' http://localhost:3000/api/reports"
    }
  end
end
