class User < ActiveRecord::Base
  has_many :invoices
  has_one :address
end
