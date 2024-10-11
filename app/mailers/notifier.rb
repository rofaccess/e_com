class Notifier < ActionMailer::Base
  default from: ENV['SMPT_USER_NAME']

  def first_purchase_mail(recipient, cc_recipients, product_name)
    @recipient = recipient
    @product_name = product_name
    mail(
      to: @recipient,
      subject: "First purchase of '#{@product_name}'",
      cc: cc_recipients
    )
  end
end
