class ProductSerializer < ActiveModel::Serializer
  attributes :name, :price, :created_by_name
end
