class RemoteInvoice < Invoice
  establish_connection :remote

  belongs_to :user, class_name: 'RemoteUser'
  has_many :line_items, class_name: 'RemoteLineItem'
end


