require 'test_helper'

class ReuseExistingRecordsTest < ActiveSupport::TestCase
  def setup
    @remote_product = RemoteProduct.create name: 'MBP', price: '2000', id: 123456
    @local_existing_product = Product.create id: @remote_product.id, name: 'MBP', price: '1000'
    @remote_line_item = RemoteLineItem.create quantity: 3, product: @remote_product
  end

  test "should reuse the referenced project when specifying a matching attribute name" do
    Forceps.configure reuse: {Product => :id}
    assert_product_was_reused_and_updated
  end

  test "should reuse the referenced project when specifying a finder" do
    Forceps.configure reuse: {Product => lambda{|remote_product| Product.find_by_name(remote_product.name)}}
    assert_product_was_reused_and_updated
  end

  test "should clone the object when it is not found" do

  end

  def assert_product_was_reused_and_updated
    Forceps::Remote::LineItem.find(@remote_line_item).copy_to_local
    assert_equal 1, Product.count
    updated_product = LineItem.find_by_quantity(3).product
    assert_identical @remote_product, updated_product
  end
end