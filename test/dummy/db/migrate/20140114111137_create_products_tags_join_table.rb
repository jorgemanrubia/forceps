class CreateProductsTagsJoinTable < ActiveRecord::Migration
  def change
    create_table :products_tags, id: false do |t|
      t.integer :product_id
      t.integer :tag_id
    end
  end
end
