class HomeController < ApplicationController
  def index
    @products = Product.includes(:product_categories).page(params[:page])
  end
end
