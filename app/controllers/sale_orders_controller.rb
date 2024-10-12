class SaleOrdersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_client, only: :create

  # GET /sale_orders
  # GET /sale_orders.json
  def index
    @sale_orders = SaleOrder.includes(:client, product: :created_by).order("sale_at DESC")
    @sale_orders = @sale_orders.where(client_id: current_user.id) if current_user.is_client?
    @sale_orders = @sale_orders.page(params[:page])

    respond_to do |format|
      format.html
      format.json { render json: @sale_orders }
    end
  end

  # POST /sale_orders
  # POST /sale_orders.json
  def create
    check_client and return
    result = PlacePurchase.call(sale_order_params.merge({"client" => current_user}))

    respond_to do |format|
      if result.success?
        sale_order = result.sale_order
        format.html { redirect_to sale_orders_path, notice: 'SaleOrder was successfully created.' }
        format.json { render json: sale_order, status: :created, location: sale_order }
      else
        format.html { redirect_to root_path, notice: result.message }
        format.json { render json: result.message, status: :unprocessable_entity }
      end
    end
  end

  private

  def sale_order_params
    params.require(:sale_order).permit(:product_id, :quantity)
  end
end
