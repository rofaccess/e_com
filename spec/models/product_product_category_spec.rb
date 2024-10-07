require 'rails_helper'

RSpec.describe ProductProductCategory, :type => :model do
  fixtures :products, :product_categories, :product_product_categories

  let(:categorized_product) { products(:jean) }

  subject(:product_product_category) {
    ProductProductCategory.new(product_id: products(:short).id, product_category_id: product_categories(:clothes).id)
  }

  it "save valid record" do
    expect(product_product_category.save).to be(true)
  end

  it "not save duplicate combination of product and product_category" do
    product_product_category.product_id = categorized_product.id
    expect {product_product_category.save}.to raise_error(ActiveRecord::RecordNotUnique)
  end
end
