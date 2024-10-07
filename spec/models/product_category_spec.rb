require 'rails_helper'

RSpec.describe ProductCategory, :type => :model do
  fixtures :users, :product_categories

  subject(:product_category) {
    ProductCategory.new(name: "Toys", created_by_id: users(:amy).id)
  }

  it "save valid record" do
    expect(product_category.save).to be(true)
  end

  it "not save duplicate name" do
    product_category.name = "Clothes"
    expect {product_category.save}.to raise_error(ActiveRecord::RecordNotUnique)
  end
end
