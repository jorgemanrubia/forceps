class RemoteInvoice < Invoice
  establish_connection 'remote'

  table_name = 'invoices'
end


