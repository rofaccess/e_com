class HomeController < ApplicationController
  def index
    @products = Product.includes(:product_categories, :product_images).page(params[:page])
  end
end
