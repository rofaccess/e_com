require 'rails_helper'

RSpec.describe "products/edit", :type => :view do
  fixtures :users

  before(:each) do
    @product = assign(:product, Product.create!(
      :name => "MyString",
      :price => "9.99",
      :created_by_id => users(:amy).id
    ))
  end

  it "renders the edit product form" do
    render

    assert_select "form[action=?][method=?]", product_path(@product), "post" do

      assert_select "input#product_name[name=?]", "product[name]"

      assert_select "input#product_price[name=?]", "product[price]"

      assert_select "input#product_created_by_id[name=?]", "product[created_by_id]"
    end
  end
end
