class RemoteUser < User
  establish_connection 'remote'
  table_name = 'users'

  has_many :invoices, class_name: 'RemoteInvoice', foreign_key: 'user_id'
end


