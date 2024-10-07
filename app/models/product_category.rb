class ProductCategory < ActiveRecord::Base
  attr_accessible :created_by_id, :name

  belongs_to :created_by, class_name: "User"
end
