# From:
# - https://www.bacancytechnology.com/blog/build-rails-api-authentication-using-jwt
# - https://www.youtube.com/watch?v=HOHEkVS9fso
# - https://dev.to/codesalley/ruby-on-rails-api-simple-authentication-with-jwt-1nfe
# - https://blog.appsignal.com/2023/08/23/secure-your-ruby-app-with-json-web-tokens.html
# - https://dev.to/mohhossain/a-complete-guide-to-rails-authentication-using-jwt-403p
# - https://medium.com/@ronakabhattrz/rails-6-7-api-authentication-with-jwt-token-based-authentication-2e2d22a70643
module JwtToken
  SECRET_TOKEN = ENV['JWT_SECRET_TOKEN']

  def self.encode(payload)
    JWT.encode(payload, SECRET_TOKEN)
  end

  def self.decode(token)
    JWT.decode(token, SECRET_TOKEN)
  end
end
