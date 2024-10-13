require "api/jwt_token"

class ReportsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_admin
  def index
    base_url = request.base_url
    @jwt_token = JwtToken.encode({ user_id: current_user.id })
    @apis = {
      deprecated_api: "curl -w '\\n' -H 'Accept: application/vnd.example.v1' -H 'Authorization: #{@jwt_token}' #{base_url}#{api_reports_path}",
      jwt_testing: "curl -w '\\n' -H 'Authorization: #{@jwt_token}' #{base_url}#{api_reports_path}",
      most_purchased_products_by_each_category: "curl -w '\\n' -H 'Authorization: #{@jwt_token}' #{base_url}#{most_purchased_products_by_each_category_api_reports_path}",
      best_selling_products_by_each_category: "curl -w '\\n' -H 'Authorization: #{@jwt_token}' #{base_url}#{best_selling_products_by_each_category_api_reports_path}"
    }
  end
end
