class Product < ActiveRecord::Base
  acts_as_paranoid
  attr_accessible :name, :price
  attr_protected :created_by_id

  belongs_to :created_by, class_name: "User"

  validates :name, presence: true

  delegate :name, to: :created_by, prefix: true
end
