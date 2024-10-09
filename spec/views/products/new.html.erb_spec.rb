require 'rails_helper'

RSpec.describe "products/new", :type => :view do
  fixtures :users, :products

  before(:each) do
    assign(:product, Product.new(name: "Name", price: 10))
  end

  it "renders new product form" do
    render
    assert_select "form[action=?][method=?]", products_path, "post" do

      assert_select "input#product_name[name=?]", "product[name]"

      assert_select "input#product_price[name=?]", "product[price]"
    end
  end
end
