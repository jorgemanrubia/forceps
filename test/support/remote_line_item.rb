class RemoteLineItem < Invoice
  establish_connection 'remote'

  belongs_to :product, class_name: 'RemoteProduct'
  belongs_to :invoice, class_name: 'RemoteInvoice'
end


