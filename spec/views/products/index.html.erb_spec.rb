require 'rails_helper'

RSpec.describe "products/index", :type => :view do
  fixtures :users

  let(:user) { users(:amy) }

  before(:each) do
    assign(:products, [
      Product.create!(
        :name => "Name",
        :price => "9.99",
        :created_by_id => user.id
      ),
      Product.create!(
        :name => "Name 2",
        :price => "9.99",
        :created_by_id => user.id
      )
    ])
  end

  it "renders a list of products" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 1
    assert_select "tr>td", :text => "Name 2".to_s, :count => 1
    assert_select "tr>td", :text => "9.99".to_s, :count => 2
    assert_select "tr>td", :text => "Amy", :count => 2
  end
end
