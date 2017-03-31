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
    remote_user = build_user_with_invoices(2)
    Forceps.configure exclude: {User => [:invoices]}

    Forceps::Remote::User.find(remote_user.id).copy_to_local

    copied_user = User.find_by_name('Jorge')
    assert_identical remote_user, copied_user
    assert_empty copied_user.invoices
  end

  test "should exclude all the associations when using :all_associations as the the 'exclude' option value" do
    remote_user = build_user_with_invoices(2)
    Forceps.configure exclude: {User => [:all_associations]}

    Forceps::Remote::User.find(remote_user.id).copy_to_local

    copied_user = User.find_by_name('Jorge')
    assert_empty copied_user.invoices
  end

  def build_user_with_invoices(invoices_count)
    RemoteUser.create!(name: 'Jorge').tap do |remote_user|
      invoices_count.times { |index| remote_user.invoices.create! number: index+1, date: "2014-1-#{index+1}" }
    end
  end
end
