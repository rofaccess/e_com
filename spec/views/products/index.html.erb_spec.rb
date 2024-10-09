require 'rails_helper'

RSpec.describe "products/index", :type => :view do
  fixtures :products

  before(:each) do
    assign(:products, [products(:jean), products(:short)])
  end

  it "renders a list of products" do
    render
    assert_select "tr>td", :text => "Jean", :count => 1
    assert_select "tr>td", :text => "Short", :count => 1
    assert_select "tr>td", :text => "20.99", :count => 1
    assert_select "tr>td", :text => "10.99", :count => 1
    assert_select "tr>td", :text => "Amy", :count => 2
  end
end
