require 'rails_helper'

RSpec.describe "products/show", :type => :view do
  fixtures :users, :products

  before(:each) do
    @product = assign(:product, products(:jean))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Jean/)
    expect(rendered).to match(/20.99/)
    expect(rendered).to match(/Amy/)
  end
end
