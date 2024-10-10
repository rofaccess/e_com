module SaleOrdersHelper
  def active_sale_orders_menu?
    active_menu?(["/sale_orders"])
  end

  def title
    current_user.is_admin? ? t('.sale_orders') : t('.purchases')
  end
end
