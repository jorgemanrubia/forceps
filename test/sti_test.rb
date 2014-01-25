require 'test_helper'

class StiTest < ActiveSupport::TestCase

  def setup
    Forceps.configure
    create_remote_car(name: 'audi')
  end

  test "should instantiate the proper remote record when fetching a record through the parent class" do
    remote_car = Forceps::Remote::Product.find_by_name('audi')
    assert_instance_of Forceps::Remote::Car, remote_car
  end

  test "should download child objects when using single table inheritance" do
    Forceps::Remote::Product.find_by_name('audi').copy_to_local
    assert_not_nil Product.find_by_name('CAR: audi')
  end

  def create_remote_car(attributes)
    RemoteProduct.create!(attributes).tap do |car|
      car.update_column :type, 'Car'
    end
  end
end