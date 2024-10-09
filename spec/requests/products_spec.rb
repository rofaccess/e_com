require 'rails_helper'

RSpec.describe "Products", :type => :request do
  fixtures :users

  let(:user) {
    users(:admin)
  }

  before do
    login_as user
  end

  describe "GET /products" do
    it "works! (now write some real specs)" do
      get products_path
      expect(response).to have_http_status(200)
    end
  end
end
