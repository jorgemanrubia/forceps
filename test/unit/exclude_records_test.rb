require 'test_helper'

class ExcludeRecordsTest < ActiveSupport::TestCase
  def setup
  end

  test "should exclude regular attributes in the 'exclude' option" do
    Forceps.configure exclude: {Address => [:street]}
    RemoteAddress.create! street: 'Uria', city: 'Oviedo'

    Forceps::Remote::Address.find_by_city('Oviedo').copy_to_local

    copied_address = Address.find_by_city('Oviedo')
    assert_nil copied_address.street
  end

  test "should exclude the associations set in the 'exclude' option" do
    remote_user = RemoteUser.create! name: 'Jorge'

    Forceps.configure exclude: {User => [:invoices]}

    2.times { |index| remote_user.invoices.create! number: index+1, date: "2014-1-#{index+1}" }

    Forceps::Remote::User.find(remote_user).copy_to_local

    copied_user = User.find_by_name('Jorge')
    assert_identical remote_user, copied_user
    assert_empty copied_user.invoices
  end
end