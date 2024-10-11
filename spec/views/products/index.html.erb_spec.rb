require 'rails_helper'

RSpec.describe "products/index", :type => :view do
  fixtures :users, :products

  let(:user) { users(:admin) }

  before(:each) do
    assign(:products, [products(:jean), products(:short)])
    allow(view).to receive(:current_user).and_return(user)
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
