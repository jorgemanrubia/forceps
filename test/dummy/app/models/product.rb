class Product < ActiveRecord::Base
  has_many :line_items
  has_and_belongs_to_many :tags
end
