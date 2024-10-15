require 'rails_helper'

RSpec.describe Reports::SaleOrder do
  describe "#sales_for_day" do
    it "return report with data for today" do
      date = Time.current
      sale_orders = Reports::SaleOrder.sales_for_day(date, 20)
      expect(sale_orders.to_a).to_not be_empty
    end

    it "return report without data for yesterday" do
      date = Time.current.yesterday
      sale_orders = Reports::SaleOrder.sales_for_day(date, 20)
      expect(sale_orders.to_a).to be_empty
    end
  end
end
