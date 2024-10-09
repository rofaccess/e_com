module ProductsHelper
  def active_products_menu?
    active_menu?(["/products"])
  end
end
