require 'test_helper'

class SimpleTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = false

  def setup
    @remote_invoice = RemoteInvoice.create! number: 123, date: Time.now
    Forceps.configure
  end

  test "should download a single record" do
    Forceps::Remote::Invoice.find_by_number(@remote_invoice.number).copy_to_local
    assert_identical @remote_invoice.becomes(Invoice), Invoice.find_by_number(123)
  end

  test "should download a record with 'has_many' associated objects" do
    @remote_user = RemoteUser.create! name: 'Jorge'
    2.times{|index| @remote_user.invoices.create number: 1, date: "2014-1-#{index}"}
    Forceps::Remote::User.find(@remote_user.id).copy_to_local

    copied_user = User.find_by_name('Jorge')
    assert_identical @remote_user, copied_user
    2.times{|index| assert_identical @remote_user.invoices[index], copied_user.invoices[index]}
  end
end