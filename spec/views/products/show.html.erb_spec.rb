require 'rails_helper'

RSpec.describe "products/show", :type => :view do
  fixtures :users

  before(:each) do
    @product = assign(:product, Product.create!(
      :name => "Name",
      :price => "9.99",
      :created_by_id => users(:amy).id
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/9.99/)
    expect(rendered).to match(/2/)
  end
end
