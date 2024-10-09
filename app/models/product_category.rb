class ProductCategory < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  attr_accessible :created_by_id, :name

  belongs_to :created_by, class_name: "User"
end
