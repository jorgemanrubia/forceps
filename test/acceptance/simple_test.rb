require 'test_helper'

class SimpleTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = false

  def setup
    @remote_invoice = RemoteInvoice.create! number: 123, date: Time.now
  end


  test "should download a single record" do
    Forceps.configure only: [Invoice]
    Forceps::Remote::Invoice.find_by_number(@remote_invoice.number).copy_to_local
    assert_identical @remote_invoice.becomes(Invoice), Invoice.find_by_number(123)
  end
end