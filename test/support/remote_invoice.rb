class RemoteInvoice < Invoice
  establish_connection 'remote'

  table_name = 'invoices'

  belongs_to :user, class_name: 'RemoteUser'
end


