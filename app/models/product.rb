class Product < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  attr_accessible :name, :price
  attr_protected :created_by_id

  belongs_to :created_by, class_name: "User"
  has_many :product_images
  accepts_nested_attributes_for :product_images, reject_if: :all_blank, allow_destroy: true

  has_many :product_product_categories
  has_many :product_categories, through: :product_product_categories
  accepts_nested_attributes_for :product_categories, allow_destroy: true

  default_scope order(:name)

  validates :name, presence: true

  delegate :name, :email, to: :created_by, prefix: true

  def first_image
    product_images.first.try(:image)
  end

  def first_image_url
    first_image.try(:url)
  end

  def product_categories_list
    product_categories.map(&:name).join(", ")
  end
end
