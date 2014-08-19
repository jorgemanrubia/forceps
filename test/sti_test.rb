require 'test_helper'

class StiTest < ActiveSupport::TestCase
  def setup
    Forceps.configure
    create_remote_car({ name: 'audi' }, 'Car')
    create_remote_car({ name: 'A1' }, 'Cars::German::CompactCar')
    create_remote_car({ name: 'R8' }, 'Cars::German::SportsCar')
  end

  test "should instantiate the proper remote record when fetching a record through the parent class" do
    remote_car = Forceps::Remote::Product.find_by_name('audi')
    assert_instance_of Forceps::Remote::Car, remote_car
  end

  test "should be able to load remote objects by the STI class" do
    remote_car = Forceps::Remote::Car.find_by_name('audi')
    assert_instance_of Forceps::Remote::Car, remote_car
  end

  test "should work with namespaced models" do
    compact_car = Forceps::Remote::Product.find_by_name('A1')
    sports_car = Forceps::Remote::Product.find_by_name('R8')
    assert_instance_of Forceps::Remote::Cars::German::CompactCar, compact_car
    assert_instance_of Forceps::Remote::Cars::German::SportsCar, sports_car
  end

  test "should use the correct type with namespaces models" do
    Forceps::Remote::Product.find_by_name('R8').copy_to_local
    assert_equal Product.find_by_name('CAR: GERMAN SPORTS CAR: R8').type, "Cars::German::SportsCar"
  end

  test "should download child objects when using single table inheritance" do
    Forceps::Remote::Product.find_by_name('audi').copy_to_local
    copied_car = Product.find_by_name('CAR: audi')
    assert_not_nil copied_car
    assert_instance_of Car, copied_car
  end

  def create_remote_car(attributes, klass)
    RemoteProduct.create!(attributes).tap do |car|
      car.update_column :type, klass
    end
  end
end