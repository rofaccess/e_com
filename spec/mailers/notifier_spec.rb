require "rails_helper"

RSpec.describe Notifier, :type => :mailer do
  fixtures :all

  describe "#daily_report_mail" do
    it "send email" do
      recipients = User.admin_emails
      date = Time.current
      sale_orders = Reports::SaleOrder.sales_for_day(date, 20)
      mail = Notifier.daily_sale_orders_report_mail(recipients, sale_orders, date).deliver

      expect(mail.from).to eq(ENV["SMPT_USER_NAME"])
      expect(mail.to).to eq(["admin@email.com"])
      expect(mail.subject).to eq("Sale orders of #{I18n.l(date.to_date, format: :long)}")

      expect(mail.body).to include("Sale orders of #{I18n.l(date.to_date, format: :long)}")

      expect(mail.body).to include('<td class="has-text-right">1</td>')
      expect(mail.body).to include('<td>Client</td>')
      expect(mail.body).to include('<td>Jean</td>')
      expect(mail.body).to include('<td>Casual Clothes, Clothes</td>')
      expect(mail.body).to include('<td>Amy</td>')
      expect(mail.body).to include('<td class="has-text-right">1</td>')
      expect(mail.body).to include('<td class="has-text-right">29,99</td>')
    end
  end
end
