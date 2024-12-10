require "api/jwt_token"

module Api
  module V2
    class UsersController < ApplicationController
      swagger_controller :reports, "User Management"

      swagger_api :authorization_token do
        summary "Fetch authorization token"
        param :query, :email, :string, :required
        param :query, :password, :string, :required
        response :unauthorized, "Invalid user or password"
      end

      def authorization_token
        email = params[:email]
        password = params[:password]

        user = User.find_for_authentication(email: email)

        if user && user.valid_password?(password)
          @jwt_token = JwtToken.encode({ user_id: user.id })
          render json: { authorization_token: @jwt_token }
        else
          render json: { msg: "Invalid user or password" }, status: :unauthorized
        end
      end

      private

      def user_params
        params.permit(:email, :password)
      end

    end
  end
end
