class RemoteLineItem < Invoice
  establish_connection 'remote'

  belongs_to :product, class_name: 'RemoteProduct'
end


