class Product < ActiveRecord::Base
  attr_accessible :created_by_id, :name, :price

  belongs_to :created_by, class_name: "User"
end
