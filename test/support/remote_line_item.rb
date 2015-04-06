class RemoteLineItem < LineItem
  establish_connection :remote

  belongs_to :product, class_name: 'RemoteProduct'
  belongs_to :invoice, class_name: 'RemoteInvoice', foreign_key: 'invoice_id'
end


