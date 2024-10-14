# From: http://railscasts.com/episodes/366-sidekiq?language=es&view=asciicast
class FirstPurchaseMailWorker
  include Sidekiq::Worker

  # Obs.: Es importante pasarle argumentos simples como String, Integer, Hash, Array, si se le pasa un objeto product
  # ocurre el error: NoMethodError (undefined method `key?' for #<JSON::Ext::Generator::State:0x000000219a3438>):
  def perform(product_id)
    product = Product.find(product_id)
    recipient = product.created_by_email
    cc_recipients = User.admin_emails(recipient)
    Notifier.first_purchase_mail(recipient, cc_recipients, product.name).deliver
  end
end
