class ProductImage < ActiveRecord::Base
  attr_accessible :image
  belongs_to :product

  default_scope order(:id)

  has_attached_file :image, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "image.svg"
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/
end
