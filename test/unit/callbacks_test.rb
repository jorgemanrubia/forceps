require 'test_helper'

class CallbacksTest < ActiveSupport::TestCase
  def setup
    @remote_product = RemoteProduct.create!(name: 'MBP', price: '2000', id: 123456).tap{|product| product.update_column :type, nil}
  end

  test "should invoke the configured 'after_each' callback" do
    after_each_callback_mock = MiniTest::Mock.new
    after_each_callback_mock.expect(:call, nil) do |args|
      assert_equal Product.find_by_name('MBP'), args[0]
      assert_identical @remote_product, args[1]
    end

    Forceps.configure :after_each => {Product => after_each_callback_mock}

    Forceps::Remote::Product.find(@remote_product).copy_to_local

    assert after_each_callback_mock.verify
  end
end