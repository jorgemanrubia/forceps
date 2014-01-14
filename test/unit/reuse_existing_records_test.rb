require 'test_helper'

class ReuseExistingRecordsTest < ActiveSupport::TestCase
  def setup
    @remote_product = RemoteProduct.create name: 'MBP', price: '2000'
    @local_existing_product = Product.create id: @remote_product.id, name: 'MBP', price: '2000'
    @remote_line_item = RemoteLineItem.create quantity: 3, product: @remote_product

    Forceps.configure reuse: [Product]
  end

  test "should reuse the referenced project instead of reusing it" do
    Forceps::Remote::LineItem.find(@remote_line_item).copy_to_local
    assert_equal 1, Product.count
    assert_equal @local_existing_product, LineItem.find_by_quantity(3).product
  end
end