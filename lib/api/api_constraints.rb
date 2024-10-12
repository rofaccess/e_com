# From: http://railscasts.com/episodes/350-rest-api-versioning?language=es&view=asciicast
class ApiConstraints
  def initialize(options)
    @version = options[:version]
    @default = options[:default]
  end

  def matches?(req)
    @default || req.headers['Accept'].include?("application/vnd.example.v#{@version}")
  end
end
