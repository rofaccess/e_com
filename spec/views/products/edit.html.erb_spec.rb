require 'rails_helper'

RSpec.describe "products/edit", :type => :view do
  fixtures :products

  before(:each) do
    @product = assign(:product, products(:jean))
  end

  it "renders the edit product form" do
    render

    assert_select "form[action=?][method=?]", product_path(@product), "post" do

      assert_select "input#product_name[name=?]", "product[name]"

      assert_select "input#product_price[name=?]", "product[price]"

      assert_select "select#product_created_by_id[name=?]", "product[created_by_id]"
    end
  end
end
