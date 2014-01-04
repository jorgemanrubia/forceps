class CreateLineItems < ActiveRecord::Migration
  def change
    create_table :line_items do |t|
      t.integer :quantity
      t.integer :product_id

      t.timestamps
    end
  end
end
