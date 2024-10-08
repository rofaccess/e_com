class ProductSerializer < ActiveModel::Serializer
  attributes :id, :name, :price, :created_by_id
end
