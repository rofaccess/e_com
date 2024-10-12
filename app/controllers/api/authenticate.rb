require "api/jwt_token"

module Api
  module Authenticate
    extend ActiveSupport::Concern

    included do
      before_filter :authenticate
    end

    def authenticate
      authorization_token = request.headers["Authorization"]
      if authorization_token
        payload = JwtToken.decode(authorization_token)
        user_id = payload[0]["user_id"]

        if User.find_by_id(user_id)
          return true
        else
          render json: { message: "User authorization fails" }, status: :unauthorized
        end
      else
        render json: { message: "Authorization header is missing" }, status: :unauthorized
      end

    rescue JWT::DecodeError
      render json: { message: "JWT Token decode error" }, status: :unauthorized
    rescue JWT::VerificationError
      render json: { message: "Invalid JWT Token" }, status: :unauthorized
    end
  end
end
