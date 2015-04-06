class RemoteUser < User
  establish_connection :remote

  has_one :address, class_name: 'RemoteAddress', foreign_key: 'user_id'
  has_many :invoices, class_name: 'RemoteInvoice', foreign_key: 'user_id'
end


