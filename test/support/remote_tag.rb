class RemoteTag < Tag
  establish_connection :remote

  has_and_belongs_to_many :products, class_name: 'RemoteProduct', join_table: 'products_tags', foreign_key: 'tag_id', association_foreign_key: 'product_id'
end


