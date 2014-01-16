class Invoice < ActiveRecord::Base
  belongs_to :user

  has_many :line_items

  has_one :address, through: :user
end
