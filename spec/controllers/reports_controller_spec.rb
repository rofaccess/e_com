require 'rails_helper'

RSpec.describe ReportsController, :type => :controller do
  fixtures :users

  let(:admin) {
    users(:admin)
  }

  before do
    sign_in admin
  end

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

end
