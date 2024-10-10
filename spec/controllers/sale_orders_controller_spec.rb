require 'rails_helper'

RSpec.describe SaleOrdersController, :type => :controller do
  fixtures :users, :products

  let(:client) {
    users(:client)
  }

  let(:product) {
    products(:jean)
  }

  before do
    sign_in client
  end

  let(:valid_attributes) {
    { product_id: product.id, quantity: 2 }
  }

  describe "GET #index" do
    it "returns a success response" do
      get :index, {}
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new SaleOrder" do
        expect {
          post :create, {:sale_order => valid_attributes}
        }.to change(SaleOrder, :count).by(1)
      end

      it "redirects to the index" do
        post :create, {:sale_order => valid_attributes}
        expect(response).to redirect_to(action: :index)
      end
    end
  end

end
