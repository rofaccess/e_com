class ProductProductCategory < ActiveRecord::Base
  attr_accessible :product_category_id, :product_id

  belongs_to :product
  belongs_to :product_category
end
