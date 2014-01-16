require 'test_helper'

class ExcludeRecordsTest < ActiveSupport::TestCase
  def setup
  end

  test "should exclude regular attributes in the 'exclude' option" do
    Forceps.configure exclude: {Address => [:street]}
    @remote_address = RemoteAddress.create! street: 'Uria', city: 'Oviedo'

    Forceps::Remote::Address.find_by_city('Oviedo').copy_to_local

    copied_address = Address.find_by_city('Oviedo')
    assert_nil copied_address.street
  end

  test "should exclude the associations set in the 'exclude' option" do

  end
end