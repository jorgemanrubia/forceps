class CreateLineItems < ActiveRecord::Migration
  def change
    create_table :line_items do |t|

      t.timestamps
    end
  end
end
