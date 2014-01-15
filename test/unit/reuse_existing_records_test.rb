require 'test_helper'

class ReuseExistingRecordsTest < ActiveSupport::TestCase
  def setup
    @remote_product = RemoteProduct.create name: 'MBP', price: '2000', id: 123456
    @local_existing_product = Product.create id: @remote_product.id, name: 'MBP', price: '2000'
    @remote_line_item = RemoteLineItem.create quantity: 3, product: @remote_product
  end

  test "should reuse the referenced project when specifying a matching attribute name" do
    Forceps.configure reuse: {Product => :id}
    assert_product_was_reused
  end

  test "should reuse the referenced project when specifying a finder" do
    Forceps.configure reuse: {Product => lambda{|product| Product.find_by_name(product.name)}}
    assert_product_was_reused
  end

  def assert_product_was_reused
    Forceps::Remote::LineItem.find(@remote_line_item).copy_to_local
    assert_equal 1, Product.count
    assert_equal @local_existing_product, LineItem.find_by_quantity(3).product
  end
end