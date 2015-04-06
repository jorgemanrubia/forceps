class RemoteAddress < Address
  establish_connection :remote

  belongs_to :user, class_name: 'RemoteUser'
end


