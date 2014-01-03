class User < ActiveRecord::Base
  has_many :invoices
end
