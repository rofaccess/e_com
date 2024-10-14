class HomeController < ApplicationController
  def index
    @q = Product.ransack(params[:q])
    @products = @q.result.includes(:product_categories, :product_images).page(params[:page])
  end
end
