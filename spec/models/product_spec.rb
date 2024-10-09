require 'rails_helper'

RSpec.describe Product, :type => :model do
  fixtures :users, :products

  subject(:product) {
    product = Product.new(name: "T-shirt", price: 9.99)
    product.created_by_id = users(:amy).id
    product
  }

  it "save valid record" do
    expect(product.save).to be(true)
  end

  it "not save duplicate name" do
    product.name = "Jean"
    expect {product.save}.to raise_error(ActiveRecord::RecordNotUnique)
  end
end
