require 'test_helper'

class ReuseExistingRecordsTest < ActiveSupport::TestCase
  def setup
    @remote_product = RemoteProduct.create!(name: 'MBP', price: '2000', id: 123456)
  end

  test "should completely ignore line items" do
    RemoteLineItem.create!(quantity: 3, product: @remote_product)
    RemoteLineItem.create!(quantity: 3, product: @remote_product)
    Forceps.configure ignore_model: ['LineItem']

    copied_product = Forceps::Remote::Product.find(@remote_product.id).copy_to_local

    assert_equal 0, copied_product.line_items.count
  end
end
