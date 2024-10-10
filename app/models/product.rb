class Product < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  attr_accessible :name, :price, :image
  attr_protected :created_by_id

  has_attached_file :image, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "image.svg"
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/

  belongs_to :created_by, class_name: "User"

  validates :name, presence: true

  delegate :name, :email, to: :created_by, prefix: true
end
