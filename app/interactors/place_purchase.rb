class PlacePurchase
  include Interactor

  def call
    context.fail!(message: "Can't create purchase. Invalid client.") unless client
    create_purchase
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

  def client
    @_client ||= context.client.is_client? ? context.client : nil
  end

  def product
    Product.find(context.product_id)
  end
end
