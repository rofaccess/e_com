require 'rails_helper'

RSpec.describe "home/index.html.erb", :type => :view do
  fixtures :products

  before(:each) do
    @products = assign(:products, Product.limit(2).page)
    @q = assign(:q, Product.ransack(params[:q]))
    allow(view).to receive(:current_user).and_return(nil)
  end

  it "renders empty page" do
    render
    assert_select ".product-item", :count => 2
  end
end
