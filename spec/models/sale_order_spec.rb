require 'rails_helper'

RSpec.describe SaleOrder, :type => :model do
  fixtures :custom_auto_increments, :sale_orders, :users, :products

  let(:client) { users(:client) }
  let(:product) { products(:jean) }

  subject(:sale_order) {
    SaleOrder.new(sale_at: Time.now, client_id: client.id, product_id: product.id, quantity: 2, price: product.price)
  }

  it "save valid record" do
    expect(sale_order.save).to be(true)
  end

  it "not save duplicate number" do
    sale_order.sale_number = "1"
    expect {sale_order.save}.to raise_error(ActiveRecord::RecordNotUnique)
  end
end
