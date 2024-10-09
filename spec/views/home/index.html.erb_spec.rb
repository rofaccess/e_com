require 'rails_helper'

RSpec.describe "home/index.html.erb", :type => :view do
  it "renders empty page" do
    render
    assert_select "h1", :text => "Welcome", :count => 1
  end
end
