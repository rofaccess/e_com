class PlacePurchase
  include Interactor

  def call
    context.fail!(message: "Can't create purchase. Invalid client.") unless client

    # Se utiliza un bloqueo pesimista para las condiciones de carrera
    product.with_lock do
      create_purchase
      notify_first_purchase if product_purchases_count == 1
    end
  end

  private

  def create_purchase
    sale_order = SaleOrder.new(
      sale_at: Time.current,
      client_id: client.id,
      product_id: product.id,
      quantity: context.quantity,
      price: product.price
    )

    if sale_order.save
      context.sale_order = sale_order
    else
      context.fail!(message: "Can't create purchase")
    end
  end

  def notify_first_purchase
    recipient = product.created_by_email
    cc_recipients = User.admin_emails
    Notifier.first_purchase_mail(recipient, cc_recipients, product.name).deliver
  end

  def product_purchases_count
    SaleOrder.where(product_id: product.id).count
  end

  def client
    @_client ||= context.client.is_client? ? context.client : nil
  end

  def product
    Product.find(context.product_id)
  end
end
