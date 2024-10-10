require 'rails_helper'

RSpec.describe PlacePurchase, type: :interactor do
  fixtures :users, :products

  let(:client) { users(:client) }
  let(:product) { products(:jean)}

  describe ".call" do
    let(:valid_params) {
      { product_id: product.id, quantity: 2 }
    }

    it "place client purchase" do
      allow_any_instance_of(PlacePurchase).to receive(:client).and_return(client)
      result = PlacePurchase.call(valid_params)
      expect(result.success?).to be_truthy
    end
  end
end
