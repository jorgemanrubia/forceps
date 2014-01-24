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
    2.times { |index| assert_identical @remote_user.invoices[index], copied_user.invoices[index] }
  end

  test "should download object with 'belongs_to'" do
    @remote_invoice = @remote_user.invoices.create! number: 1234, date: "2014-1-3"

    Forceps::Remote::Invoice.find(@remote_invoice).copy_to_local

    copied_invoice = Invoice.find_by_number(1234)
    assert_identical @remote_invoice, copied_invoice
  end

  test "should download objects with 'has_and_belongs_to_many'" do
    remote_tags = 2.times.collect { |index| RemoteTag.create name: "tag #{index}" }
    remote_products = 2.times.collect do |index|
      RemoteProduct.create(name: "product #{index}").tap do |product|
        product.update_column :type, nil # we don't STI here
      end
    end
    remote_products.each { |remote_product| remote_tags.each {|remote_tag| remote_product.tags << remote_tag} }

    Forceps::Remote::Tag.find(remote_tags[0]).copy_to_local

    assert_equal 2, Product.count
    assert_equal 2, Tag.count

    2.times do |index|
      assert_not_nil tag = Tag.find_by_name("tag #{index}")
      assert_not_nil Product.find_by_name("product #{index}")
      assert_equal 2, tag.products.count
    end
  end

  test "should download object with 'has_one'" do
    remote_address = RemoteAddress.create!(street: 'Uria', city: 'Oviedo', country: 'Spain', user: @remote_user)

    Forceps::Remote::User.find(@remote_user).copy_to_local

    copied_user = User.find_by_name('Jorge')
    assert_identical remote_address, copied_user.address
  end

  test "should download child objects when using single table inheritance" do
    remote_car = RemoteProduct.create!(name: 'audi')
    remote_car.update_column :type, 'Car'

    Forceps::Remote::Product.find_by_name('audi').copy_to_local
    assert_not_nil Product.find_by_name('CAR: audi')
  end

end