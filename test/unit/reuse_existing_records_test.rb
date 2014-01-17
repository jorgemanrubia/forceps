require 'test_helper'

class ReuseExistingRecordsTest < ActiveSupport::TestCase
  def setup
    @remote_product = RemoteProduct.create!(name: 'MBP', price: '2000', id: 123456).tap{|product| product.update_column :type, nil}
    @local_existing_product = Product.create!(id: @remote_product.id, name: 'MBP', price: '1000')
    @remote_line_item = RemoteLineItem.create! quantity: 3, product: @remote_product
  end

  test "should reuse the referenced project when specifying a matching attribute name" do
    Forceps.configure reuse: {Product => :id}
    Forceps::Remote::LineItem.find(@remote_line_item).copy_to_local
    assert_product_was_reused_and_updated
  end

  test "should reuse the referenced project when specifying a finder" do
    Forceps.configure reuse: {Product => lambda{|remote_product| Product.find_by_name(remote_product.name)}}
    Forceps::Remote::LineItem.find(@remote_line_item).copy_to_local
    assert_product_was_reused_and_updated
  end

  test "should clone the object when it is not found" do
    Forceps.configure reuse: {Product => lambda{|remote_product| Product.find_by_price('some not-existing price')}}
    Forceps::Remote::LineItem.find(@remote_line_item).copy_to_local
    assert_product_was_created
  end

  def assert_product_was_reused_and_updated
    assert_product_was_copied(1)
  end

  def assert_product_was_created
    assert_product_was_copied(2)
  end

  def assert_product_was_copied(expected_product_count)
    assert_equal expected_product_count, Product.count
    updated_product = LineItem.find_by_quantity(3).product
    assert_identical @remote_product, updated_product
  end
end