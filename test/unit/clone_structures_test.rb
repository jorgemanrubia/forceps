require 'test_helper'

class CloneStructuresTest < ActiveSupport::TestCase

  def setup
    @remote_invoice = RemoteInvoice.create! number: 123, date: Time.now
    @remote_user = RemoteUser.create! name: 'Jorge'
    Forceps.configure
  end

  test "should download a single record" do
    Forceps::Remote::Invoice.find_by_number(@remote_invoice.number).copy_to_local
    assert_identical @remote_invoice.becomes(Invoice), Invoice.find_by_number(123)
  end

  test "should download object with 'has_many'" do
    2.times { |index| @remote_user.invoices.create! number: index+1, date: "2014-1-#{index+1}" }

    Forceps::Remote::User.find(@remote_user).copy_to_local

    copied_user = User.find_by_name('Jorge')
    assert_identical @remote_user, copied_user
    2.times { |index| assert_identical @remote_user.invoices[index], copied_user.invoices[index]}
  end

  test "should download object with 'belongs_to'" do
    @remote_invoice = @remote_user.invoices.create! number: 1234, date: "2014-1-3"

    Forceps::Remote::Invoice.find(@remote_invoice).copy_to_local

    copied_invoice = Invoice.find_by_number(1234)
    assert_identical @remote_invoice, copied_invoice
  end

  test "should download object with 'has_one'" do
    remote_address = RemoteAddress.create!(street: 'Uria', city: 'Oviedo', country: 'Spain', user: @remote_user)

    Forceps::Remote::User.find(@remote_user).copy_to_local

    copied_user = User.find_by_name('Jorge')
    assert_identical remote_address, copied_user.address
  end

end