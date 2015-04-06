class RemoteProduct < Product
  establish_connection :remote

  has_many :line_items, class_name: 'RemoteLineItem', foreign_key: 'product_id'
  has_and_belongs_to_many :tags, class_name: 'RemoteTag', join_table: 'products_tags', foreign_key: 'product_id', association_foreign_key: 'tag_id'
end


